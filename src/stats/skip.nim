type
  SkipOperation = proc(row0, col0, row1, col1: int): int {.closure.}

proc processSkipgram(stat: string, op: SkipOperation, fing: Finger = 0) =
  var skipStat = SkipStat(
    ngrams: newSeq[int](),
    weight: newSeq[float](SkipLength)
  )
  
  # Initialize weights
  for i in 0..<SkipLength:
    skipStat.weight[i] = -Inf

  for i in 0..<Dim2:
    var row0, col0, row1, col1: int
    unflatBi(i, row0, col0, row1, col1)
    if op(row0, col0, row1, col1) == 1 and (fing == 0 or finger(row0, col0) == fing):
      skipStat.ngrams.add(i)

  skipStats[stat] = skipStat

proc initializeSkipgramStats() =
  const
    fingerNames: array[8, string] = [
      "Left Pinky Skipgram",
      "Left Ring Skipgram",
      "Left Middle Skipgram",
      "Left Index Skipgram",
      "Right Index Skipgram",
      "Right Middle Skipgram",
      "Right Ring Skipgram",
      "Right Pinky Skipgram"
    ]

    badFingerNames: array[8, string] = [
      "Bad Left Pinky Skipgram",
      "Bad Left Ring Skipgram",
      "Bad Left Middle Skipgram",
      "Bad Left Index Skipgram",
      "Bad Right Index Skipgram",
      "Bad Right Middle Skipgram",
      "Bad Right Ring Skipgram",
      "Bad Right Pinky Skipgram"
    ]

  # Same Finger Skipgram
  processSkipgram("Same Finger Skipgram", isSameFingerBi)

  # Per Finger Skipgrams
  for fing in 0..7:
    processSkipgram(fingerNames[fing], isSameFingerBi, fing)

  # Bad Same Finger Skipgram
  processSkipgram("Bad Same Finger Skipgram", isBadSameFingerBi)

  # Per Finger Bad Skipgrams
  for fing in 0..7:
    processSkipgram(badFingerNames[fing], isBadSameFingerBi, fing)