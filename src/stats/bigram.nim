type
  BiOperation = proc(row0, col0, row1, col1: int): int {.closure.}

proc processBigram(stat: string, op: BiOperation, fing: int = -1) =
  var biStat = BiStat(
    ngrams: newSeq[int](),
    weight: -Inf
  )
  for i in 0..<Dim2:
    var row0, col0, row1, col1: int
    unflatBi(i, row0, col0, row1, col1)
    if op(row0, col0, row1, col1) == 1 and (fing == -1 or finger(row0, col0) == fing):
      biStat.ngrams.add(i)

  biStats[stat] = biStat

proc initializeBigramStats() =
  const 
    fingerStatNames: array[8, string] = [
      "Left Pinky Bigram",
      "Left Ring Bigram",
      "Left Middle Bigram",
      "Left Index Bigram",
      "Right Index Bigram",
      "Right Middle Bigram",
      "Right Ring Bigram",
      "Right Pinky Bigram"
    ]

    badFingerStatNames: array[8, string] = [
      "Bad Left Pinky Bigram",
      "Bad Left Ring Bigram",
      "Bad Left Middle Bigram",
      "Bad Left Index Bigram",
      "Bad Right Index Bigram",
      "Bad Right Middle Bigram",
      "Bad Right Ring Bigram",
      "Bad Right Pinky Bigram"
    ]

  # Same Finger Bigram
  processBigram("Same Finger Bigram", isSameFingerBi)

  # Finger-specific Bigrams
  for fing in 0..7:
    processBigram(fingerStatNames[fing], isSameFingerBi, fing)

  # Bad Same Finger Bigram
  processBigram("Bad Same Finger Bigram", isBadSameFingerBi)

  # Bad Finger-specific Bigrams
  for fing in 0..7:
    processBigram(badFingerStatNames[fing], isBadSameFingerBi, fing)

  # Russor stats
  processBigram("Full Russor Bigram", isFullRussor)
  processBigram("Half Russor Bigram", isHalfRussor)

  # LSBs
  processBigram("Index Stretch Bigram", isIndexStretchBi)
  processBigram("Pinky Stretch Bigram", isPinkyStretchBi)