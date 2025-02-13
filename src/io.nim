# Set the log level
addHandler(newConsoleLogger(fmtStr = "$datetime | $levelname | "))
setLogFilter(lvlDebug)  # Set the minimum log level

type LayoutConfig = object
  matrix: array[Row, array[Col, int]]
  name: string

type
  LangError = object of CatchableError

proc convertChar(c: char): int =
  let value = charTable.getOrDefault(Rune(c), 0)
  if value == 0: -1 else: value

proc isValid(idx: int): bool =
  idx in 0..<langLength

proc checkDuplicates(arr: seq[Rune]): int =
  ## Checks for duplicate characters in language definition, excluding adjacent pairs
  ## Returns -1 if no duplicates found, otherwise returns count of duplicate pairs
  result = -1
  for i in 0..<arr.len:
    for j in (i+2)..<arr.len:
      if arr[i] == arr[j] and arr[i] != Rune('@'):
        inc result

proc readLang(langName: string) =
  ## Reads a language definition file and builds a character mapping table.
  ## The file must:
  ##  - Begin with exactly two spaces
  ##  - Contain no more than 100 characters
  ##  - Have no duplicates (except adjacent pairs for shifted characters)
  ##  - Not contain the '@' character (reserved)
  charTable.clear()

  let path = "./data/" & langName & "/" & langName & ".lang"

  proc error(msg: string) =
    raise newException(LangError, msg)

  var langFile: File
  try:
    langFile = open(path)
  except IOError:
    error("Lang file not found.")
  defer: langFile.close()

  while langArr.len <= MaxLangSize:
    try:
      let c = langFile.readChar()
      if c == '\0' or c == '\n':
        langArr.add(Rune('@'))
      elif c == '@':
        error("'@' found in lang, illegal character.")
      else:
        langArr.add(Rune(c))
    except EOFError:
      if langArr.len < MaxLangSize:
        langArr.add(Rune('@'))
      break

  if langArr.len < 2 or langArr[0] != Rune(' ') or langArr[1] != Rune(' '):
    error("Lang file must begin with 2 spaces")

  if langArr.len > MaxLangSize:
    error("Lang file too long (>" & $MaxLangSize & " characters)")

  if checkDuplicates(langArr) != -1:
    error("Lang file contains duplicate characters.")

  # Build character mapping table
  for i, rune in langArr:
    if rune == Rune('@'):
      charTable[Rune('@')] = -1
    else:
      charTable[rune] = i div 2

  langLength = (charTable.len - 1) div 2

proc getCharCode(c: Rune): int =
  ## Gets the position code for a character in the language.
  ## Returns -1 if the character is not in the language.
  charTable.getOrDefault(c, -1)

proc readLayoutConfig(layoutName: string): LayoutConfig =
  ## Reads a keyboard layout from a .glg file and returns just the raw configuration
  result.name = layoutName

  let path = "./data/" & "/layouts/" & layoutName & ".glg"

  try:
    let file = open(path)
    defer: file.close()

    var row = 0
    for line in file.lines:
      if row >= Row: break

      var col = 0
      for c in strutils.splitWhitespace(line):
        if col >= Col: break

        # Convert @ to -1, otherwise convert to character code
        if c == "@":
          result.matrix[row][col] = -1
        else:
          result.matrix[row][col] = convertChar(c[0]).int

        inc col
      inc row
  except IOError:
    raise newException(IOError, "Layout file not found. Failed to open or read: " & path)

proc readFingerMap(path: string): FingerMap =
  # Start with default stretches and adjacent pairs
  result = initDefaultFingerMap()

  let configPath = path & ".json"

  var jsonContent: string
  try:
    jsonContent = readFile(configPath)
  except IOError:
    raise newException(IOError, "Failed to read finger map config: " & configPath)

  var config: JsonNode
  try:
    config = parseJson(jsonContent)
  except JsonParsingError:
    raise newException(JsonParsingError, "Invalid JSON in finger map config: " & configPath)

  if not config.hasKey("fingerAssignments"):
    raise newException(ValueError, "Missing 'fingerAssignments' in config: " & configPath)

  let assignments = config["fingerAssignments"]

  # Validate array dimensions exactly match Row x Col
  if assignments.len != Row:
    raise newException(ValueError, "Expected " & $Row & " rows, got " & $assignments.len)

  for row in 0..<Row:
    if assignments[row].len != Col:
      raise newException(ValueError, "Row " & $row & " expected " & $Col &
                        " columns, got " & $assignments[row].len)

    for col in 0..<Col:
      let fingerStr = assignments[row][col].getStr()
      if fingerStr == "@":
        result.assignments[row][col] = none(Finger)
      else:
        try:
          result.assignments[row][col] = some(parseEnum[Finger](fingerStr))
        except ValueError:
          raise newException(ValueError,
            "Invalid finger value '" & fingerStr & "' at position [" & $row & "][" & $col & "]")

proc readLayout(layoutName: string): Layout =
  ## Reads a keyboard layout from a .glg file and returns the layout configuration

  result.name = layoutName

  let path = "./data/" & "/layouts/" & layoutName & ".glg"

  try:
    let file = open(path)
    defer: file.close()

    var row = 0
    for line in file.lines:
      if row >= Row: break

      var col = 0
      for c in strutils.splitWhitespace(line):
        if col >= Col: break

        # Convert @ to -1, otherwise convert to character code
        if c == "@":
          result.matrix[row][col] = -1
        else:
          result.matrix[row][col] = convertChar(c[0]).int

        inc col
      inc row

  except IOError:
    raise newException(IOError, "Layout file not found. Failed to open or read: " & path)

  # Initialize score tables
  result.monoScore = initTable[string, float]()
  result.biScore = initTable[string, float]()
  result.triScore = initTable[string, float]()
  result.quadScore = initTable[string, float]()
  result.skipScore = initTable[string, array[SkipLength, float]]()

  # Initialize scores
  for name in monoStats.keys:
    result.monoScore[name] = 0.0
  for name in biStats.keys:
    result.biScore[name] = 0.0
  for name in triStats.keys:
    result.triScore[name] = 0.0
  for name in quadStats.keys:
    result.quadScore[name] = 0.0

  var zeroArray: array[SkipLength, float]
  for name in skipStats.keys:
    result.skipScore[name] = zeroArray

proc cleanAscii(filename: string): string =
  try:
    var file = open(filename)
    defer: file.close()
    result = ""
    var runes = file.readAll().toRunes
    for c in runes:
      if c.int >= 32 and c.int <= 126:  # ASCII printable range
        result.add(c.toUTF8)
      elif c.int != 10 and c.int != 13 and c.int != 9:  # Skip newline, CR, and tab
        echo "Unicode value: ", c.int, " Character: ", $c  # Directly show the character with $c
  except IOError:
    raise newException(IOError, "Corpus file not found, make sure the file ends in .txt. Failed to open")

proc rotateRight(mem: var openArray[int]) =
  ## Shifts all elements in the array one position to the right, discarding the last element.
  for i in countdown(mem.len - 1, 1):
    mem[i] = mem[i - 1]
  mem[0] = -1  # Reset the first element

proc readCorpus(langName, corpusName: string) =
  let path = "./data/" & langName & "/" & "/corpora/" & corpusName & ".txt"
  let cleanedText = cleanAscii(path)
  var mem = @[-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1]

  initCorpusArrays()

  for c in cleanedText:
    mem[0] = convertChar(c)

    if mem[0] > 0:
      inc corpusMono[mem[0]]

      if mem[1] > 0:
        inc corpusBi[mem[1]][mem[0]]

        if mem[2] > 0:
          inc corpusTri[mem[2]][mem[1]][mem[0]]

          if mem[3] > 0:
            inc corpusQuad[mem[3]][mem[2]][mem[1]][mem[0]]

      for i in 2..10:
        if mem[i] > 0:
          inc corpusSkip[i-2][mem[i]][mem[0]]

    mem.rotateRight()

proc updateStats[T](stats: var Table[string, T], name: string, weights: openArray[float]) =
 if name in stats:
   var stat = stats[name]
   when T is SkipStat:
     for i in 0..<min(weights.len, stat.weight.len):
       stat.weight[i] = weights[i]
   else:
     if weights.len > 0:
       stat.weight = weights[0]
   stats[name] = stat

proc readWeights(weightName: string) =
 let path = "./data/weights/" & weightName & ".wght"
 if not fileExists(path):
   raise newException(IOError, "Weights file not found: " & path)

 let file = open(path, fmRead)
 defer: file.close()

 var seenMetrics = initHashSet[string]()

 for line in file.lines:
   let parts = line.split(':')
   if parts.len < 2: continue

   let name = parts[0].strip()
   var weights: seq[float] = @[]

   for token in strutils.splitWhitespace(parts[1].strip()):
     try:
       weights.add(parseFloat(token))
     except ValueError:
       error "Invalid weight: ", token
       continue

   seenMetrics.incl(name)

   if not (name in monoStats or name in biStats or
           name in triStats or name in quadStats or
           name in skipStats or name in metaStats):
     error "Unknown metric in weights file: ", name
     continue

   template tryUpdate(statsTable) =
     if name in statsTable:
       updateStats(statsTable, name, weights)
       continue

   tryUpdate(monoStats)
   tryUpdate(biStats)
   tryUpdate(triStats)
   tryUpdate(quadStats)
   tryUpdate(skipStats)
   tryUpdate(metaStats)

 for statName in monoStats.keys:
   if statName notin seenMetrics:
     error "Missing weight for metric: ", statName
 for statName in biStats.keys:
   if statName notin seenMetrics:
     error "Missing weight for metric: ", statName
 for statName in triStats.keys:
   if statName notin seenMetrics:
     error "Missing weight for metric: ", statName
 for statName in quadStats.keys:
   if statName notin seenMetrics:
     error "Missing weight for metric: ", statName
 for statName in skipStats.keys:
   if statName notin seenMetrics:
     error "Missing weight for metric: ", statName
 for statName in metaStats.keys:
   if statName notin seenMetrics:
     error "Missing weight for metric: ", statName

proc fingerSortKey(name: string): int =
  let n = name.toLowerAscii

  case n
  # Monogram usage - matches first 17 entries
  of "left outer usage": 0
  of "left pinky usage": 1
  of "left ring usage": 2
  of "left middle usage": 3
  of "left index usage": 4
  of "left inner usage": 5
  of "right inner usage": 6
  of "right index usage": 7
  of "right middle usage": 8
  of "right ring usage": 9
  of "right pinky usage": 10
  of "right outer usage": 11
  of "left hand usage": 12
  of "right hand usage": 13
  of "top row usage": 14
  of "home row usage": 15
  of "bottom row usage": 16

  # Bigrams - next 22 entries
  of "same finger bigram": 17
  of "left pinky bigram": 18
  of "left ring bigram": 19
  of "left middle bigram": 20
  of "left index bigram": 21
  of "right index bigram": 22
  of "right middle bigram": 23
  of "right ring bigram": 24
  of "right pinky bigram": 25
  of "bad same finger bigram": 26
  of "bad left pinky bigram": 27
  of "bad left ring bigram": 28
  of "bad left middle bigram": 29
  of "bad left index bigram": 30
  of "bad right index bigram": 31
  of "bad right middle bigram": 32
  of "bad right ring bigram": 33
  of "bad right pinky bigram": 34
  of "full russor bigram": 35
  of "half russor bigram": 36
  of "index stretch bigram": 37
  of "pinky stretch bigram": 38

  # Trigrams through Quadgrams - matches middle section
  of "same finger trigram": 39
  of "redirect": 40
  of "bad redirect": 41
  of "alternation": 42
  of "alternation in": 43
  of "alternation out": 44
  of "same row alternation": 45
  of "same row alternation in": 46
  of "same row alternation out": 47
  of "adjacent finger alternation": 48
  of "adjacent finger alternation in": 49
  of "adjacent finger alternation out": 50
  of "same row adjacent finger alternation": 51
  of "same row adjacent finger alternation in": 52
  of "same row adjacent finger alternation out": 53
  of "one hand": 54
  of "one hand in": 55
  of "one hand out": 56
  of "same row one hand": 57
  of "same row one hand in": 58
  of "same row one hand out": 59
  of "adjacent finger one hand": 60
  of "adjacent finger one hand in": 61
  of "adjacent finger one hand out": 62
  of "same row adjacent finger one hand": 63
  of "same row adjacent finger one hand in": 64
  of "same row adjacent finger one hand out": 65
  of "roll": 66
  of "roll in": 67
  of "roll out": 68
  of "same row roll": 69
  of "same row roll in": 70
  of "same row roll out": 71
  of "adjacent finger roll": 72
  of "adjacent finger roll in": 73
  of "adjacent finger roll out": 74
  of "same row adjacent finger roll": 75
  of "same row adjacent finger roll in": 76
  of "same row adjacent finger roll out": 77
  of "same finger quadgram": 78
  of "chained redirect": 79
  of "bad chained redirect": 80
  of "chained alternation": 81
  of "chained alternation in": 82
  of "chained alternation out": 83
  of "chained alternation mix": 84
  of "same row chained alternation": 85
  of "same row chained alternation in": 86
  of "same row chained alternation out": 87
  of "same row chained alternation mix": 88
  of "adjacent finger chained alternation": 89
  of "adjacent finger chained alternation in": 90
  of "adjacent finger chained alternation out": 91
  of "adjacent finger chained alternation mix": 92
  of "same row adjacent finger chained alternation": 93
  of "same row adjacent finger chained alternation in": 94
  of "same row adjacent finger chained alternation out": 95
  of "same row adjacent finger chained alternation mix": 96
  of "quad one hand": 97
  of "quad one hand in": 98
  of "quad one hand out": 99
  of "quad same row one hand": 100
  of "quad same row one hand in": 101
  of "quad same row one hand out": 102
  of "quad adjacent finger one hand": 103
  of "quad adjacent finger one hand in": 104
  of "quad adjacent finger one hand out": 105
  of "quad same row adjacent finger one hand": 106
  of "quad same row adjacent finger one hand in": 107
  of "quad same row adjacent finger one hand out": 108
  of "quad roll": 109
  of "quad roll in": 110
  of "quad roll out": 111
  of "quad same row roll": 112
  of "quad same row roll in": 113
  of "quad same row roll out": 114
  of "quad adjacent finger roll": 115
  of "quad adjacent finger roll in": 116
  of "quad adjacent finger roll out": 117
  of "quad same row adjacent finger roll": 118
  of "quad same row adjacent finger roll in": 119
  of "quad same row adjacent finger roll out": 120
  of "true roll": 121
  of "true roll in": 122
  of "true roll out": 123
  of "same row true roll": 124
  of "same row true roll in": 125
  of "same row true roll out": 126
  of "adjacent finger true roll": 127
  of "adjacent finger true roll in": 128
  of "adjacent finger true roll out": 129
  of "same row adjacent finger true roll": 130
  of "same row adjacent finger true roll in": 131
  of "same row adjacent finger true roll out": 132
  of "chained roll": 133
  of "chained roll in": 134
  of "chained roll out": 135
  of "chained roll mix": 136
  of "same row chained roll": 137
  of "same row chained roll in": 138
  of "same row chained roll out": 139
  of "same row chained roll mix": 140
  of "adjacent finger chained roll": 141
  of "adjacent finger chained roll in": 142
  of "adjacent finger chained roll out": 143
  of "adjacent finger chained roll mix": 144
  of "same row adjacent finger chained roll": 145
  of "same row adjacent finger chained roll in": 146
  of "same row adjacent finger chained roll out": 147
  of "same row adjacent finger chained roll mix": 148

  # Skipgrams - matches final section before Hand Balance
  of "same finger skipgram": 149
  of "left pinky skipgram": 150
  of "left ring skipgram": 151
  of "left middle skipgram": 152
  of "left index skipgram": 153
  of "right index skipgram": 154
  of "right middle skipgram": 155
  of "right ring skipgram": 156
  of "right pinky skipgram": 157
  of "bad same finger skipgram": 158
  of "bad left pinky skipgram": 159
  of "bad left ring skipgram": 160
  of "bad left middle skipgram": 161
  of "bad left index skipgram": 162
  of "bad right index skipgram": 163
  of "bad right middle skipgram": 164
  of "bad right ring skipgram": 165
  of "bad right pinky skipgram": 166

  # Meta stat - last entry
  of "hand balance": 167

  else: 1000  # Everything else alphabetically

proc statCompare(x, y: string): int =
  ## Custom comparison function for sorting stats
  let xKey = fingerSortKey(x)
  let yKey = fingerSortKey(y)
  if xKey != yKey:
    result = cmp(xKey, yKey)
  else:
    result = cmp(x, y)  # Alphabetical sort for same key or non-finger stats

proc convertBack(i: int): char =
  ## Converts an index in the language array back to its corresponding character.
  ##
  ## Parameters:
  ##   i: The index to convert.
  ##
  ## Returns:
  ##   The character corresponding to the index, or '@' if out of bounds.

  if i >= 0 and i < langLength:
    result = char(langArr[i * 2])  # Get lowercase version from even indices
  else:
    result = '@'

proc quietPrint(lt: Layout) =
  ## Prints the layout name, keyboard matrix, and score.
  ##
  ## Parameters:
  ##   lt: The layout to be printed

  # Print layout name
  echo("\n", lt.name)

  # Print keyboard matrix
  for row in lt.matrix:
    var line = ""
    for key in row:
      line.add(convertBack(key) & " ")
    echo(line)

  # Print score
  echo("score : ", formatFloat(lt.score, ffDefault, 6), "\n")

proc normalPrint*(lt: Layout) =
  ## Prints the layout along with all ngram stats.
  ## Finger usage stats are sorted from left pinky to right pinky,
  ## followed by hand stats, then everything else alphabetically.

  # Print basic layout info
  quietPrint(lt)

  # Print monogram stats
  echo("\nMONOGRAM STATS")
  for name in toSeq(lt.monoScore.keys).sorted(statCompare):
    echo(name, " : ", formatFloat(lt.monoScore[name], ffDefault, 6), "%")

  # Print bigram stats
  echo("\nBIGRAM STATS")
  for name in toSeq(lt.biScore.keys).sorted(statCompare):
    echo(name, " : ", formatFloat(lt.biScore[name], ffDefault, 6), "%")

  # Print trigram stats
  echo("\nTRIGRAM STATS")
  for name in toSeq(lt.triScore.keys).sorted(statCompare):
    echo(name, " : ", formatFloat(lt.triScore[name], ffDefault, 6), "%")

  # Print quadgram stats
  echo("\nQUADGRAM STATS")
  for name in toSeq(lt.quadScore.keys).sorted(statCompare):
    echo(name, " : ", formatFloat(lt.quadScore[name], ffDefault, 6), "%")

  # Print skipgram stats
  echo("\nSKIPGRAM STATS")
  for name in toSeq(lt.skipScore.keys).sorted(statCompare):
    var line = name & " : "
    for i in 0..<lt.skipScore[name].len:
      line.add(formatFloat(lt.skipScore[name][i], ffDefault, 6))
      line.add("|")
    echo(line)

  # Print meta stats
  echo("\nMETA STATS")
  if lt.metaScore.isSome:
    echo("Hand Balance : ", formatFloat(lt.metaScore.get(), ffDefault, 6), "%")

proc verbosePrint(lt: Layout) =
  ## Prints detailed information, currently the same as normalPrint.
  ##
  ## Parameters:
  ##   lt: The layout to be printed
  normalPrint(lt)

proc printLayout(lt: Layout) =
  ## Prints the contents of a layout structure to the standard output.
  ## Uses the current outputMode to determine the level of detail to print,
  ## ranging from just the layout matrix and score to detailed statistics
  ## for each ngram type.
  ##
  ## Parameters:
  ##   lt: The layout to be printed

  case outputMode
  of Quiet:
    quietPrint(lt)
  of Normal:
    normalPrint(lt)
  of Verbose:
    verbosePrint(lt)
