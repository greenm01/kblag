const
  SkipLength = 9
  UnicodeMax = 65535
  MaxLangSize = 100  # Maximum allowed characters in a language definition file

var
  langLength: int
  charTable = initOrderedTable[Rune, int]()
  langArr = newSeq[Rune]()

  corpusMono: seq[int]
  corpusBi: seq[seq[int]]
  corpusTri: seq[seq[seq[int]]]
  corpusQuad: seq[seq[seq[seq[int]]]]
  corpusSkip: seq[seq[seq[int]]]

  linearMono: seq[float]
  linearBi: seq[float]
  linearTri: seq[float]
  linearQuad: seq[float]
  linearSkip: seq[float]

type OutputMode = enum
  Quiet = 'q'
  Normal = 'n'
  Verbose = 'v'

var outputMode = OutputMode.Normal  # Default output mode

proc initCorpusArrays() =

  # Note that index [0] is reserved for invalid characters

  # Monogram
  corpusMono = newSeq[int](langLength)

  # Bigram
  corpusBi = newSeq[seq[int]](langLength)
  for i in 0..<langLength:
    corpusBi[i] = newSeq[int](langLength)

  # Trigram
  corpusTri = newSeq[seq[seq[int]]](langLength)
  for i in 0..<langLength:
    corpusTri[i] = newSeq[seq[int]](langLength)
    for j in 0..<langLength:
      corpusTri[i][j] = newSeq[int](langLength)

  # Quadgram
  corpusQuad = newSeq[seq[seq[seq[int]]]](langLength)
  for i in 0..<langLength:
    corpusQuad[i] = newSeq[seq[seq[int]]](langLength)
    for j in 0..<langLength:
      corpusQuad[i][j] = newSeq[seq[int]](langLength)
      for k in 0..<langLength:
        corpusQuad[i][j][k] = newSeq[int](langLength)

  # Skipgram
  corpusSkip = newSeq[seq[seq[int]]](SkipLength)
  for i in 0..<SkipLength:
    corpusSkip[i] = newSeq[seq[int]](langLength)
    for j in 0..<langLength:
      corpusSkip[i][j] = newSeq[int](langLength)

  # Linear arrays
  linearMono = newSeq[float](langLength)
  linearBi = newSeq[float](langLength * langLength)
  linearTri = newSeq[float](langLength * langLength * langLength)
  linearQuad = newSeq[float](langLength * langLength * langLength * langLength)
  linearSkip = newSeq[float](SkipLength * langLength * langLength)
