type
  SkipOperation = proc(map: FingerMap, row0, col0, row1, col1: uint8): bool {.closure.}

proc processSkipgram(map: FingerMap, stat: string, op: SkipOperation, targetFinger: Option[Finger] = none(Finger)) =
  var skipStat = SkipStat(
    ngrams: newSeq[PackedBi](),
    weight: newSeq[float](SkipLength)
  )
  # Initialize weights
  for i in 0..<SkipLength:
    skipStat.weight[i] = -Inf

  for row0 in countup(Row):
    for col0 in countup(Col):
      if targetFinger.isSome:
        let f = getFinger(map, row0, col0)
        if f.isNone or f.get != targetFinger.get:
          continue
      for row1 in countup(Row):
        for col1 in countup(Col):
          if op(map, row0, col0, row1, col1):
            skipStat.ngrams.add(packBi(row0, col0, row1, col1))

  skipStats[stat] = skipStat

proc initializeSkipgramStats(map: FingerMap) =
  const
    fingerNames = {
      LP: "Left Pinky Skipgram",
      LR: "Left Ring Skipgram",
      LM: "Left Middle Skipgram",
      LI: "Left Index Skipgram",
      RI: "Right Index Skipgram",
      RM: "Right Middle Skipgram",
      RR: "Right Ring Skipgram",
      RP: "Right Pinky Skipgram"
    }.toTable

    badFingerNames = {
      LP: "Bad Left Pinky Skipgram",
      LR: "Bad Left Ring Skipgram",
      LM: "Bad Left Middle Skipgram",
      LI: "Bad Left Index Skipgram",
      RI: "Bad Right Index Skipgram",
      RM: "Bad Right Middle Skipgram",
      RR: "Bad Right Ring Skipgram",
      RP: "Bad Right Pinky Skipgram"
    }.toTable

  # Same Finger Skipgram
  processSkipgram(map, "Same Finger Skipgram",
    proc(map: FingerMap, row0, col0, row1, col1: uint8): bool {.closure.} =
      isSameFingerSkip(map, 0, row0, col0, row1, col1))

  # Per Finger Skipgrams
  for finger in Finger:
    processSkipgram(map, fingerNames[finger],
      proc(map: FingerMap, row0, col0, row1, col1: uint8): bool {.closure.} =
        isSameFingerSkip(map, 0, row0, col0, row1, col1),
      some(finger))

  # Bad Same Finger Skipgram
  processSkipgram(map, "Bad Same Finger Skipgram",
    proc(map: FingerMap, row0, col0, row1, col1: uint8): bool {.closure.} =
      isBadSameFingerSkip(map, 0, row0, col0, row1, col1))

  # Per Finger Bad Skipgrams
  for finger in Finger:
    processSkipgram(map, badFingerNames[finger],
      proc(map: FingerMap, row0, col0, row1, col1: uint8): bool {.closure.} =
        isBadSameFingerSkip(map, 0, row0, col0, row1, col1),
      some(finger))
