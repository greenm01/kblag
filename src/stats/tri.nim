type
  TriOperation = proc(map: FingerMap, row0, col0, row1, col1, row2, col2: int): bool {.closure.}

proc processTrigram(map: FingerMap, stat: string, op: TriOperation) =
  var triStat = TriStat(
    ngrams: newSeq[int](),
    weight: -Inf
  )
  for i in 0..<Dim3:
    var row0, col0, row1, col1, row2, col2: int
    unflatTri(i, row0, col0, row1, col1, row2, col2)
    if op(map, row0, col0, row1, col1, row2, col2):
      triStat.ngrams.add(i)

  triStats[stat] = triStat

proc initializeTrigramStats(map: FingerMap) =
  # Helper template to reduce repetition
  template addTrigram(name: string, checker: untyped) =
    processTrigram(map, name,
      proc(map: FingerMap, row0, col0, row1, col1, row2, col2: int): bool =
        checker(map, row0, col0, row1, col1, row2, col2))

  # Basic trigrams
  addTrigram("Same Finger Trigram", isSameFingerTri)
  addTrigram("Redirect", isRedirect)
  addTrigram("Bad Redirect", isBadRedirect)

  # Alternation trigrams
  addTrigram("Alternation", isAlt)
  addTrigram("Alternation In", isAltIn)
  addTrigram("Alternation Out", isAltOut)

  # Same row alternation trigrams
  addTrigram("Same Row Alternation", isSameRowAlt)
  addTrigram("Same Row Alternation In", isSameRowAltIn)
  addTrigram("Same Row Alternation Out", isSameRowAltOut)

  # Adjacent finger alternation trigrams
  addTrigram("Adjacent Finger Alternation", isAdjacentFingerAlt)
  addTrigram("Adjacent Finger Alternation In", isAdjacentFingerAltIn)
  addTrigram("Adjacent Finger Alternation Out", isAdjacentFingerAltOut)

  # Same row adjacent finger alternation trigrams
  addTrigram("Same Row Adjacent Finger Alternation", isSameRowAdjacentFingerAlt)
  addTrigram("Same Row Adjacent Finger Alternation In", isSameRowAdjacentFingerAltIn)
  addTrigram("Same Row Adjacent Finger Alternation Out", isSameRowAdjacentFingerAltOut)

  # One hand trigrams
  addTrigram("One Hand", isOneHand)
  addTrigram("One Hand In", isOneHandIn)
  addTrigram("One Hand Out", isOneHandOut)

  # Same row one hand trigrams
  addTrigram("Same Row One Hand", isSameRowOneHand)
  addTrigram("Same Row One Hand In", isSameRowOneHandIn)
  addTrigram("Same Row One Hand Out", isSameRowOneHandOut)

  # Adjacent finger one hand trigrams
  addTrigram("Adjacent Finger One Hand", isAdjacentFingerOneHand)
  addTrigram("Adjacent Finger One Hand In", isAdjacentFingerOneHandIn)
  addTrigram("Adjacent Finger One Hand Out", isAdjacentFingerOneHandOut)

  # Same row adjacent finger one hand trigrams
  addTrigram("Same Row Adjacent Finger One Hand", isSameRowAdjacentFingerOneHand)
  addTrigram("Same Row Adjacent Finger One Hand In", isSameRowAdjacentFingerOneHandIn)
  addTrigram("Same Row Adjacent Finger One Hand Out", isSameRowAdjacentFingerOneHandOut)

  # Roll trigrams
  addTrigram("Roll", isRoll)
  addTrigram("Roll In", isRollIn)
  addTrigram("Roll Out", isRollOut)

  # Same row roll trigrams
  addTrigram("Same Row Roll", isSameRowRoll)
  addTrigram("Same Row Roll In", isSameRowRollIn)
  addTrigram("Same Row Roll Out", isSameRowRollOut)

  # Adjacent finger roll trigrams
  addTrigram("Adjacent Finger Roll", isAdjacentFingerRoll)
  addTrigram("Adjacent Finger Roll In", isAdjacentFingerRollIn)
  addTrigram("Adjacent Finger Roll Out", isAdjacentFingerRollOut)

  # Same row adjacent finger roll trigrams
  addTrigram("Same Row Adjacent Finger Roll", isSameRowAdjacentFingerRoll)
  addTrigram("Same Row Adjacent Finger Roll In", isSameRowAdjacentFingerRollIn)
  addTrigram("Same Row Adjacent Finger Roll Out", isSameRowAdjacentFingerRollOut)
