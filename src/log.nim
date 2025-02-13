proc logCharTable() =
  echo "charTable:"
  for c, value in charTable.pairs:
    echo "rune '", $c, "' (", c.int, ") -> ", value

proc logCorpusMono() =
  echo "corpusMono:"
  for i in 0..<langLength:
    echo "Index ", i, ": ", corpusMono[i]

proc logCorpusBi() =
  echo "corpusBi:"
  for i in 0..<langLength:
    for j in 0..<langLength:
      if corpusBi[i][j] > 0:
        echo "(", i, ", ", j, ") -> ", corpusBi[i][j]

proc logCorpusTri() =
  echo "corpusTri:"
  for i in 0..<langLength:
    for j in 0..<langLength:
      for k in 0..<langLength:
        if corpusTri[i][j][k] > 0:
          echo "(", i, ", ", j, ", ", k, ") -> ", corpusTri[i][j][k]

proc logCorpusQuad() =
  echo "corpusQuad:"
  for i in 0..<langLength:
    for j in 0..<langLength:
      for k in 0..<langLength:
        for l in 0..<langLength:
          if corpusQuad[i][j][k][l] > 0:
            echo "(", i, ", ", j, ", ", k, ", ", l, ") -> ", corpusQuad[i][j][k][l]

proc logCorpusSkip() =
  echo "corpusSkip:"
  for skip in 0..<SkipLength:
    for i in 0..<langLength:
      for j in 0..<langLength:
        if corpusSkip[skip][i][j] > 0:
          echo "Skip ", skip, " (", i, ", ", j, ") -> ", corpusSkip[skip][i][j]

proc echoFingerMap(fm: FingerMap) =
  echo "\n=== FingerMap Debug Output ==="

  echo "\nAssignments Matrix:"
  for row in 0..<Row:
    var rowStr = ""
    for col in 0..<Col:
      let fingerOpt = fm.assignments[row][col]
      if fingerOpt.isSome:
        rowStr &= $fingerOpt.get & "\t"
      else:
        rowStr &= "@\t"
    echo rowStr

  echo "\nAdjacent Pairs:"
  for pair in fm.adjacentPairs:
    echo "  ", pair[0], " <-> ", pair[1]

  echo "\nStretches (row,col):"
  for stretch in fm.stretches:
    echo "  ", stretch[0], ",", stretch[1]

  echo "\nHand Balance:"
  for hand, value in fm.handBalance:
    echo "  ", hand, ": ", value.formatFloat(ffDecimal, 2)

  echo "\nFinger Loads:"
  for finger, load in fm.fingerLoads:
    echo "  ", finger, ": ", load.formatFloat(ffDecimal, 2)

  echo "==========================\n"
