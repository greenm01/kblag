type
  QuadOperation = proc(row0, col0, row1, col1, row2, col2, row3, col3: int): int

proc processQuadgram(stat: string, op: QuadOperation) =
  var quadStat = QuadStat(
    ngrams: newSeq[int](),
    weight: -Inf
  )
  for i in 0..<Dim4:
    var row0, col0, row1, col1, row2, col2, row3, col3: int
    unflatQuad(i, row0, col0, row1, col1, row2, col2, row3, col3)
    if op(row0, col0, row1, col1, row2, col2, row3, col3) == 1:
      quadStat.ngrams.add(i)
  
  quadStats[stat] = quadStat

proc initializeQuadgramStats*() =
  # Helper template to reduce repetition and improve readability
  template addQuad(name: string, checker: untyped) =
    processQuadgram(name, checker)

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
      addQuad(prefix & "Chained Alternation" & suffix, checker)

  # Group 3: One Hand Quadgrams
  const oneHandVariants = [
    ("", isOneHandQuad),
    (" In", isOneHandQuadIn),
    (" Out", isOneHandQuadOut)
  ]

  for prefix in ["Quad ", "Quad Same Row ", "Quad Adjacent Finger ", "Quad Same Row Adjacent Finger "]:
    for (suffix, checker) in oneHandVariants:
      addQuad(prefix & "One Hand" & suffix, checker)

  # Group 4: Roll Quadgrams
  const rollVariants = [
    ("", isRollQuad),
    (" In", isRollQuadIn),
    (" Out", isRollQuadOut)
  ]

  for prefix in ["Quad ", "Quad Same Row ", "Quad Adjacent Finger ", "Quad Same Row Adjacent Finger "]:
    for (suffix, checker) in rollVariants:
      addQuad(prefix & "Roll" & suffix, checker)

  # Group 5: True Roll variants
  const trueRollVariants = [
    ("", isTrueRoll),
    (" In", isTrueRollIn),
    (" Out", isTrueRollOut)
  ]

  for prefix in ["", "Same Row ", "Adjacent Finger ", "Same Row Adjacent Finger "]:
    for (suffix, checker) in trueRollVariants:
      addQuad(prefix & "True Roll" & suffix, checker)

  # Group 6: Chained Roll variants
  const chainedRollVariants = [
    ("", isChainedRoll),
    (" In", isChainedRollIn),
    (" Out", isChainedRollOut),
    (" Mix", isChainedRollMix)
  ]

  for prefix in ["", "Same Row ", "Adjacent Finger ", "Same Row Adjacent Finger "]:
    for (suffix, checker) in chainedRollVariants:
      addQuad(prefix & "Chained Roll" & suffix, checker)