proc logCharTable() =
  echo "charTable:"
  for i in 32..126:
    let c = char(i)
    #if charTable[i] != 0:  # Only print valid mappings
    echo "char '", c, "' (", i, ") -> ", charTable[i]

proc logCorpusMono() =
  echo "corpusMono:"
  for i in 0..<LangLength:
    echo "Index ", i, ": ", corpusMono[i]

proc logCorpusBi() =
  echo "corpusBi:"
  for i in 0..<LangLength:
    for j in 0..<LangLength:
      if corpusBi[i][j] > 0:
        echo "(", i, ", ", j, ") -> ", corpusBi[i][j]

proc logCorpusTri() =
  echo "corpusTri:"
  for i in 0..<LangLength:
    for j in 0..<LangLength:
      for k in 0..<LangLength:
        if corpusTri[i][j][k] > 0:
          echo "(", i, ", ", j, ", ", k, ") -> ", corpusTri[i][j][k]

proc logCorpusQuad() =
  echo "corpusQuad:"
  for i in 0..<LangLength:
    for j in 0..<LangLength:
      for k in 0..<LangLength:
        for l in 0..<LangLength:
          if corpusQuad[i][j][k][l] > 0:
            echo "(", i, ", ", j, ", ", k, ", ", l, ") -> ", corpusQuad[i][j][k][l]

proc logCorpusSkip() =
  echo "corpusSkip:"
  for skip in 0..<SkipLength:
    for i in 0..<LangLength:
      for j in 0..<LangLength:
        if corpusSkip[skip][i][j] > 0:
          echo "Skip ", skip, " (", i, ", ", j, ") -> ", corpusSkip[skip][i][j]