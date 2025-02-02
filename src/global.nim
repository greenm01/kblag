const
  English = "  aAbBcCdDeEfFgGhHiIjJkKlLmMnNoOpPqQrRsStTuUvVwWxXyYzZ/?.>,<;:-_'\"=+[{]}"
  LangLength = English.len div 2  # 72 / 2 = 36 unique keys
  SkipLength = 9

var
  charTable: array[32..126, int]  # Only printable ASCII range
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
  corpusMono = newSeq[int](LangLength)

  # Bigram
  corpusBi = newSeq[seq[int]](LangLength)
  for i in 0..<LangLength:
    corpusBi[i] = newSeq[int](LangLength)

  # Trigram
  corpusTri = newSeq[seq[seq[int]]](LangLength)
  for i in 0..<LangLength:
    corpusTri[i] = newSeq[seq[int]](LangLength)
    for j in 0..<LangLength:
      corpusTri[i][j] = newSeq[int](LangLength)

  # Quadgram
  corpusQuad = newSeq[seq[seq[seq[int]]]](LangLength)
  for i in 0..<LangLength:
    corpusQuad[i] = newSeq[seq[seq[int]]](LangLength)
    for j in 0..<LangLength:
      corpusQuad[i][j] = newSeq[seq[int]](LangLength)
      for k in 0..<LangLength:
        corpusQuad[i][j][k] = newSeq[int](LangLength)

  # Skipgram
  corpusSkip = newSeq[seq[seq[int]]](SkipLength)
  for i in 0..<SkipLength:
    corpusSkip[i] = newSeq[seq[int]](LangLength)
    for j in 0..<LangLength:
      corpusSkip[i][j] = newSeq[int](LangLength)

  # Linear arrays
  linearMono = newSeq[float](LangLength)
  linearBi = newSeq[float](LangLength * LangLength)
  linearTri = newSeq[float](LangLength * LangLength * LangLength)
  linearQuad = newSeq[float](LangLength * LangLength * LangLength * LangLength)
  linearSkip = newSeq[float](SkipLength * LangLength * LangLength)