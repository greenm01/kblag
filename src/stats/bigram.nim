type
  BiOperation = proc(map: FingerMap, row0, col0, row1, col1: int): bool {.closure.}

proc processBigram(map: FingerMap, stat: string, op: BiOperation, targetFinger: Option[Finger] = none(Finger)) =
  var biStat = BiStat(
    ngrams: newSeq[PackedBi](),
    weight: -Inf
  )

  for row0 in 0..<Row:
    for col0 in 0..<Col:
      if targetFinger.isSome:
        let f = getFinger(map, row0, col0)
        if f.isNone or f.get != targetFinger.get:
          continue

      for row1 in 0..<Row:
        for col1 in 0..<Col:
          if op(map, row0, col0, row1, col1):
            biStat.ngrams.add(packBi(row0, col0, row1, col1))

  biStats[stat] = biStat

proc initializeBigramStats(map: FingerMap) =
  let fingerStatNames: array[8, string] = [
    "Left Pinky Bigram",     # ord(LP) = 0
    "Left Ring Bigram",      # ord(LR) = 1
    "Left Middle Bigram",    # ord(LM) = 2
    "Left Index Bigram",     # ord(LI) = 3
    "Right Index Bigram",    # ord(RI) = 4
    "Right Middle Bigram",   # ord(RM) = 5
    "Right Ring Bigram",     # ord(RR) = 6
    "Right Pinky Bigram"     # ord(RP) = 7
  ]

  let badFingerStatNames: array[8, string] = [
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
  processBigram(map, "Same Finger Bigram", isSameFingerBi)

  # Finger-specific Bigrams
  for finger in Finger:
    processBigram(map, fingerStatNames[ord(finger)], isSameFingerBi, some(finger))

  # Bad Same Finger Bigram
  processBigram(map, "Bad Same Finger Bigram", isBadSameFingerBi)

  # Bad Finger-specific Bigrams
  for finger in Finger:
    processBigram(map, badFingerStatNames[ord(finger)], isBadSameFingerBi, some(finger))

  # Russor stats
  processBigram(map, "Full Russor Bigram", isFullRussor)
  processBigram(map, "Half Russor Bigram", isHalfRussor)

  # LSBs
  processBigram(map, "Index Stretch Bigram", isIndexStretchBi)
  processBigram(map, "Pinky Stretch Bigram", isPinkyStretchBi)
