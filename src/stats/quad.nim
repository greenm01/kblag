type
  QuadOperation = proc(map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: int): bool {.closure.}

proc processQuadgram(map: FingerMap, stat: string, op: QuadOperation) =
  var quadStat = QuadStat(
    ngrams: newSeq[int](),
    weight: -Inf
  )
  for i in 0..<Dim4:
    var row0, col0, row1, col1, row2, col2, row3, col3: int
    unflatQuad(i, row0, col0, row1, col1, row2, col2, row3, col3)
    if op(map, row0, col0, row1, col1, row2, col2, row3, col3):
      quadStat.ngrams.add(i)

  quadStats[stat] = quadStat

proc initializeQuadgramStats(map: FingerMap) =
  # Helper template to reduce repetition and improve readability
  template addQuad(name: string, checker: untyped) =
    processQuadgram(map, name, checker)

  # Group 1: Basic Quadgrams
  addQuad("Same Finger Quadgram", isSameFingerQuad)
  addQuad("Chained Redirect", isChainedRedirect)
  addQuad("Bad Chained Redirect", isBadChainedRedirect)

  # Group 2: Chained Alternation variants
  const altVariants = [
    ("", isChainedAlt),
    (" In", isChainedAltIn),
    (" Out", isChainedAltOut),
    (" Mix", isChainedAltMix)
  ]

  for prefix in ["", "Same Row ", "Adjacent Finger ", "Same Row Adjacent Finger "]:
    for (suffix, checker) in altVariants:
      addQuad(prefix & "Chained Alternation" & suffix,
        proc(map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: int): bool =
          checker(map, row0, col0, row1, col1, row2, col2, row3, col3))

  # Group 3: One Hand Quadgrams
  const oneHandVariants = [
    ("", isOneHandQuad),
    (" In", isOneHandQuadIn),
    (" Out", isOneHandQuadOut)
  ]

  for prefix in ["Quad ", "Quad Same Row ", "Quad Adjacent Finger ", "Quad Same Row Adjacent Finger "]:
    for (suffix, checker) in oneHandVariants:
      addQuad(prefix & "One Hand" & suffix,
        proc(map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: int): bool =
          checker(map, row0, col0, row1, col1, row2, col2, row3, col3))

  # Group 4: Roll Quadgrams
  const rollVariants = [
    ("", isRollQuad),
    (" In", isRollQuadIn),
    (" Out", isRollQuadOut)
  ]

  for prefix in ["Quad ", "Quad Same Row ", "Quad Adjacent Finger ", "Quad Same Row Adjacent Finger "]:
    for (suffix, checker) in rollVariants:
      addQuad(prefix & "Roll" & suffix,
        proc(map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: int): bool =
          checker(map, row0, col0, row1, col1, row2, col2, row3, col3))

  # Group 5: True Roll variants
  const trueRollVariants = [
    ("", isTrueRoll),
    (" In", isTrueRollIn),
    (" Out", isTrueRollOut)
  ]

  for prefix in ["", "Same Row ", "Adjacent Finger ", "Same Row Adjacent Finger "]:
    for (suffix, checker) in trueRollVariants:
      addQuad(prefix & "True Roll" & suffix,
        proc(map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: int): bool =
          checker(map, row0, col0, row1, col1, row2, col2, row3, col3))

  # Group 6: Chained Roll variants
  const chainedRollVariants = [
    ("", isChainedRoll),
    (" In", isChainedRollIn),
    (" Out", isChainedRollOut),
    (" Mix", isChainedRollMix)
  ]

  for prefix in ["", "Same Row ", "Adjacent Finger ", "Same Row Adjacent Finger "]:
    for (suffix, checker) in chainedRollVariants:
      addQuad(prefix & "Chained Roll" & suffix,
        proc(map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: int): bool =
          checker(map, row0, col0, row1, col1, row2, col2, row3, col3))
