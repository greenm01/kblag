# Basic pattern checks
proc isSameHandQuad(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  let
    f1 = getFinger(map, row0, col0)
    f2 = getFinger(map, row1, col1)
    f3 = getFinger(map, row2, col2)
    f4 = getFinger(map, row3, col3)
  isSameHand(f1, f2) and isSameHand(f2, f3) and isSameHand(f3, f4)

proc isSameColQuad(row0, col0, row1, col1, row2, col2, row3, col3: uint8): bool =
  col0 == col1 and col1 == col2 and col2 == col3

proc isSameRowQuad(row0, col0, row1, col1, row2, col2, row3, col3: uint8): bool =
  row0 == row1 and row1 == row2 and row2 == row3

proc isSameRowModQuad(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  row0 == row1 and row1 == row2 and row2 == row3 and not isStretch(map, row0, col0) and
    not isStretch(map, row1, col1) and not isStretch(map, row2, col2) and
    not isStretch(map, row3, col3)

proc isSamePosQuad(row0, col0, row1, col1, row2, col2, row3, col3: uint8): bool =
  isSameColQuad(row0, col0, row1, col1, row2, col2, row3, col3) and
    isSameRowQuad(row0, col0, row1, col1, row2, col2, row3, col3)

proc isAdjacentFingerQuad(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  let
    f1 = getFinger(map, row0, col0)
    f2 = getFinger(map, row1, col1)
    f3 = getFinger(map, row2, col2)
    f4 = getFinger(map, row3, col3)

  if f1.isNone or f2.isNone or f3.isNone or f4.isNone:
    return false

  not isStretch(map, row0, col0) and not isStretch(map, row1, col1) and
    not isStretch(map, row2, col2) and not isStretch(map, row3, col3) and
    isAdjacent(map, f1, f2) and isAdjacent(map, f2, f3) and isAdjacent(map, f3, f4) and
    f1 != f2 and f2 != f3 and f3 != f4

proc isSameFingerQuad(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  let
    f1 = getFinger(map, row0, col0)
    f2 = getFinger(map, row1, col1)
    f3 = getFinger(map, row2, col2)
    f4 = getFinger(map, row3, col3)

  f1 == f2 and f2 == f3 and f3 == f4 and f1.isSome and
    not isSamePosBi(row0, col0, row1, col1) and not isSamePosBi(row1, col1, row2, col2) and
    not isSamePosBi(row2, col2, row3, col3)

# Chained Redirect patterns
proc isChainedRedirect(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isRedirect(map, row0, col0, row1, col1, row2, col2) and
    isRedirect(map, row1, col1, row2, col2, row3, col3)

proc isBadChainedRedirect(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isBadRedirect(map, row0, col0, row1, col1, row2, col2) and
    isBadRedirect(map, row1, col1, row2, col2, row3, col3)

# Chained Alternation patterns
proc isChainedAlt(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isAlt(map, row0, col0, row1, col1, row2, col2) and
    isAlt(map, row1, col1, row2, col2, row3, col3)

proc isChainedAltIn(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isAltIn(map, row0, col0, row1, col1, row2, col2) and
    isAltIn(map, row1, col1, row2, col2, row3, col3)

proc isChainedAltOut(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isAltOut(map, row0, col0, row1, col1, row2, col2) and
    isAltOut(map, row1, col1, row2, col2, row3, col3)

proc isChainedAltMix(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  (
    isAltIn(map, row0, col0, row1, col1, row2, col2) and
    isAltOut(map, row1, col1, row2, col2, row3, col3)
  ) or (
    isAltOut(map, row0, col0, row1, col1, row2, col2) and
    isAltIn(map, row1, col1, row2, col2, row3, col3)
  )

# Same Row Chained Alternation patterns
proc isChainedSameRowAlt(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isSameRowAlt(map, row0, col0, row1, col1, row2, col2) and
    isSameRowAlt(map, row1, col1, row2, col2, row3, col3)

proc isChainedSameRowAltIn(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isSameRowAltIn(map, row0, col0, row1, col1, row2, col2) and
    isSameRowAltIn(map, row1, col1, row2, col2, row3, col3)

proc isChainedSameRowAltOut(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isSameRowAltOut(map, row0, col0, row1, col1, row2, col2) and
    isSameRowAltOut(map, row1, col1, row2, col2, row3, col3)

proc isChainedSameRowAltMix(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  (
    isSameRowAltIn(map, row0, col0, row1, col1, row2, col2) and
    isSameRowAltOut(map, row1, col1, row2, col2, row3, col3)
  ) or (
    isSameRowAltOut(map, row0, col0, row1, col1, row2, col2) and
    isSameRowAltIn(map, row1, col1, row2, col2, row3, col3)
  )

# Adjacent Finger Chained Alternation patterns
proc isChainedAdjacentFingerAlt(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isAdjacentFingerAlt(map, row0, col0, row1, col1, row2, col2) and
    isAdjacentFingerAlt(map, row1, col1, row2, col2, row3, col3)

proc isChainedAdjacentFingerAltIn(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isAdjacentFingerAltIn(map, row0, col0, row1, col1, row2, col2) and
    isAdjacentFingerAltIn(map, row1, col1, row2, col2, row3, col3)

proc isChainedAdjacentFingerAltOut(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isAdjacentFingerAltOut(map, row0, col0, row1, col1, row2, col2) and
    isAdjacentFingerAltOut(map, row1, col1, row2, col2, row3, col3)

proc isChainedAdjacentFingerAltMix(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  (
    isAdjacentFingerAltIn(map, row0, col0, row1, col1, row2, col2) and
    isAdjacentFingerAltOut(map, row1, col1, row2, col2, row3, col3)
  ) or (
    isAdjacentFingerAltOut(map, row0, col0, row1, col1, row2, col2) and
    isAdjacentFingerAltIn(map, row1, col1, row2, col2, row3, col3)
  )

# Same Row Adjacent Finger Chained Alternation patterns
proc isChainedSameRowAdjacentFingerAlt(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isSameRowAdjacentFingerAlt(map, row0, col0, row1, col1, row2, col2) and
    isSameRowAdjacentFingerAlt(map, row1, col1, row2, col2, row3, col3)

proc isChainedSameRowAdjacentFingerAltIn(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isSameRowAdjacentFingerAltIn(map, row0, col0, row1, col1, row2, col2) and
    isSameRowAdjacentFingerAltIn(map, row1, col1, row2, col2, row3, col3)

proc isChainedSameRowAdjacentFingerAltOut(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isSameRowAdjacentFingerAltOut(map, row0, col0, row1, col1, row2, col2) and
    isSameRowAdjacentFingerAltOut(map, row1, col1, row2, col2, row3, col3)

proc isChainedSameRowAdjacentFingerAltMix(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  (
    isSameRowAdjacentFingerAltIn(map, row0, col0, row1, col1, row2, col2) and
    isSameRowAdjacentFingerAltOut(map, row1, col1, row2, col2, row3, col3)
  ) or (
    isSameRowAdjacentFingerAltOut(map, row0, col0, row1, col1, row2, col2) and
    isSameRowAdjacentFingerAltIn(map, row1, col1, row2, col2, row3, col3)
  )

# One Hand Quad patterns
proc isOneHandQuad(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  let
    f1 = getFinger(map, row0, col0)
    f2 = getFinger(map, row1, col1)
    f3 = getFinger(map, row2, col2)
    f4 = getFinger(map, row3, col3)

  if f1.isNone or f2.isNone or f3.isNone or f4.isNone:
    return false

  isSameHandQuad(map, row0, col0, row1, col1, row2, col2, row3, col3) and (
    (
      ord(f1.get) < ord(f2.get) and ord(f2.get) < ord(f3.get) and
      ord(f3.get) < ord(f4.get)
    ) or (
      ord(f1.get) > ord(f2.get) and ord(f2.get) > ord(f3.get) and
      ord(f3.get) > ord(f4.get)
    )
  )

proc isOneHandQuadIn(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  let
    f1 = getFinger(map, row0, col0)
    f2 = getFinger(map, row1, col1)
    f3 = getFinger(map, row2, col2)
    f4 = getFinger(map, row3, col3)

  if f1.isNone or f2.isNone or f3.isNone or f4.isNone:
    return false

  isOneHandQuad(map, row0, col0, row1, col1, row2, col2, row3, col3) and (
    (
      getHand(f1) == some(Left) and ord(f1.get) < ord(f2.get) and
      ord(f2.get) < ord(f3.get) and ord(f3.get) < ord(f4.get)
    ) or (
      getHand(f1) == some(Right) and ord(f1.get) > ord(f2.get) and
      ord(f2.get) > ord(f3.get) and ord(f3.get) > ord(f4.get)
    )
  )

proc isOneHandQuadOut(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isOneHandQuad(map, row0, col0, row1, col1, row2, col2, row3, col3) and
    not isOneHandQuadIn(map, row0, col0, row1, col1, row2, col2, row3, col3)

# Same Row One Hand Quad patterns
proc isSameRowOneHandQuad(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isOneHandQuad(map, row0, col0, row1, col1, row2, col2, row3, col3) and
    isSameRowModQuad(map, row0, col0, row1, col1, row2, col2, row3, col3)

proc isSameRowOneHandQuadIn(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isOneHandQuadIn(map, row0, col0, row1, col1, row2, col2, row3, col3) and
    isSameRowModQuad(map, row0, col0, row1, col1, row2, col2, row3, col3)

proc isSameRowOneHandQuadOut(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isOneHandQuadOut(map, row0, col0, row1, col1, row2, col2, row3, col3) and
    isSameRowModQuad(map, row0, col0, row1, col1, row2, col2, row3, col3)

# Adjacent Finger One Hand Quad patterns
proc isAdjacentFingerOneHandQuad(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isOneHandQuad(map, row0, col0, row1, col1, row2, col2, row3, col3) and
    isAdjacentFingerQuad(map, row0, col0, row1, col1, row2, col2, row3, col3)

proc isAdjacentFingerOneHandQuadIn(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isOneHandQuadIn(map, row0, col0, row1, col1, row2, col2, row3, col3) and
    isAdjacentFingerQuad(map, row0, col0, row1, col1, row2, col2, row3, col3)

proc isAdjacentFingerOneHandQuadOut(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isOneHandQuadOut(map, row0, col0, row1, col1, row2, col2, row3, col3) and
    isAdjacentFingerQuad(map, row0, col0, row1, col1, row2, col2, row3, col3)

# Same Row Adjacent Finger One Hand Quad patterns
proc isSameRowAdjacentFingerOneHandQuad(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isOneHandQuad(map, row0, col0, row1, col1, row2, col2, row3, col3) and
    isSameRowModQuad(map, row0, col0, row1, col1, row2, col2, row3, col3) and
    isAdjacentFingerQuad(map, row0, col0, row1, col1, row2, col2, row3, col3)

proc isSameRowAdjacentFingerOneHandQuadIn(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isOneHandQuadIn(map, row0, col0, row1, col1, row2, col2, row3, col3) and
    isSameRowModQuad(map, row0, col0, row1, col1, row2, col2, row3, col3) and
    isAdjacentFingerQuad(map, row0, col0, row1, col1, row2, col2, row3, col3)

proc isSameRowAdjacentFingerOneHandQuadOut(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isOneHandQuadOut(map, row0, col0, row1, col1, row2, col2, row3, col3) and
    isSameRowModQuad(map, row0, col0, row1, col1, row2, col2, row3, col3) and
    isAdjacentFingerQuad(map, row0, col0, row1, col1, row2, col2, row3, col3)

# Roll Quad patterns
proc isRollQuad(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  (
    isOneHand(map, row0, col0, row1, col1, row2, col2) and
    not isSameHandBi(map, row2, col2, row3, col3)
  ) or (
    not isSameHandBi(map, row0, col0, row1, col1) and
    isOneHand(map, row1, col1, row2, col2, row3, col3)
  )

proc isRollQuadIn(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  (
    isOneHandIn(map, row0, col0, row1, col1, row2, col2) and
    not isSameHandBi(map, row2, col2, row3, col3)
  ) or (
    not isSameHandBi(map, row0, col0, row1, col1) and
    isOneHandIn(map, row1, col1, row2, col2, row3, col3)
  )

proc isRollQuadOut(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isRollQuad(map, row0, col0, row1, col1, row2, col2, row3, col3) and
    not isRollQuadIn(map, row0, col0, row1, col1, row2, col2, row3, col3)

# Same Row Roll Quad patterns
proc isSameRowRollQuad(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isRollQuad(map, row0, col0, row1, col1, row2, col2, row3, col3) and (
    (
      isOneHand(map, row0, col0, row1, col1, row2, col2) and
      isSameRowOneHand(map, row0, col0, row1, col1, row2, col2)
    ) or (
      isOneHand(map, row1, col1, row2, col2, row3, col3) and
      isSameRowOneHand(map, row1, col1, row2, col2, row3, col3)
    )
  )

proc isSameRowRollQuadIn(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isSameRowRollQuad(map, row0, col0, row1, col1, row2, col2, row3, col3) and
    isRollQuadIn(map, row0, col0, row1, col1, row2, col2, row3, col3)

proc isSameRowRollQuadOut(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isSameRowRollQuad(map, row0, col0, row1, col1, row2, col2, row3, col3) and
    isRollQuadOut(map, row0, col0, row1, col1, row2, col2, row3, col3)

# Adjacent Finger Roll Quad patterns
proc isAdjacentFingerRollQuad(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isRollQuad(map, row0, col0, row1, col1, row2, col2, row3, col3) and (
    (
      isOneHand(map, row0, col0, row1, col1, row2, col2) and
      isAdjacentFingerOneHand(map, row0, col0, row1, col1, row2, col2)
    ) or (
      isOneHand(map, row1, col1, row2, col2, row3, col3) and
      isAdjacentFingerOneHand(map, row1, col1, row2, col2, row3, col3)
    )
  )

proc isAdjacentFingerRollQuadIn(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isAdjacentFingerRollQuad(map, row0, col0, row1, col1, row2, col2, row3, col3) and
    isRollQuadIn(map, row0, col0, row1, col1, row2, col2, row3, col3)

proc isAdjacentFingerRollQuadOut(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isAdjacentFingerRollQuad(map, row0, col0, row1, col1, row2, col2, row3, col3) and
    isRollQuadOut(map, row0, col0, row1, col1, row2, col2, row3, col3)

# Same Row Adjacent Finger Roll Quad patterns
proc isSameRowAdjacentFingerRollQuad(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isRollQuad(map, row0, col0, row1, col1, row2, col2, row3, col3) and (
    (
      isOneHand(map, row0, col0, row1, col1, row2, col2) and
      isSameRowAdjacentFingerOneHand(map, row0, col0, row1, col1, row2, col2)
    ) or (
      isOneHand(map, row1, col1, row2, col2, row3, col3) and
      isSameRowAdjacentFingerOneHand(map, row1, col1, row2, col2, row3, col3)
    )
  )

proc isSameRowAdjacentFingerRollQuadIn(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isSameRowAdjacentFingerRollQuad(map, row0, col0, row1, col1, row2, col2, row3, col3) and
    isRollQuadIn(map, row0, col0, row1, col1, row2, col2, row3, col3)

proc isSameRowAdjacentFingerRollQuadOut(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isSameRowAdjacentFingerRollQuad(map, row0, col0, row1, col1, row2, col2, row3, col3) and
    isRollQuadOut(map, row0, col0, row1, col1, row2, col2, row3, col3)

# True Roll patterns
proc isTrueRoll(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  not isSameHandBi(map, row0, col0, row1, col1) and
    isSameHandBi(map, row1, col1, row2, col2) and
    not isSameHandBi(map, row2, col2, row3, col3) and
    not isSameFingerBi(map, row1, col1, row2, col2) and
    not isSamePosBi(row1, col1, row2, col2)

proc isTrueRollIn(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isTrueRoll(map, row0, col0, row1, col1, row2, col2, row3, col3) and
    isRollIn(map, row0, col0, row1, col1, row2, col2)

proc isTrueRollOut(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isTrueRoll(map, row0, col0, row1, col1, row2, col2, row3, col3) and
    isRollOut(map, row0, col0, row1, col1, row2, col2)

# Same Row True Roll patterns
proc isSameRowTrueRoll(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isTrueRoll(map, row0, col0, row1, col1, row2, col2, row3, col3) and
    isSameRowModBi(map, row1, col1, row2, col2)

proc isSameRowTrueRollIn(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isTrueRollIn(map, row0, col0, row1, col1, row2, col2, row3, col3) and
    isSameRowModBi(map, row1, col1, row2, col2)

proc isSameRowTrueRollOut(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isTrueRollOut(map, row0, col0, row1, col1, row2, col2, row3, col3) and
    isSameRowModBi(map, row1, col1, row2, col2)

# Adjacent Finger True Roll patterns
proc isAdjacentFingerTrueRoll(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isTrueRoll(map, row0, col0, row1, col1, row2, col2, row3, col3) and
    isAdjacentFingerBi(map, row1, col1, row2, col2)

proc isAdjacentFingerTrueRollIn(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isTrueRollIn(map, row0, col0, row1, col1, row2, col2, row3, col3) and
    isAdjacentFingerBi(map, row1, col1, row2, col2)

proc isAdjacentFingerTrueRollOut(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isTrueRollOut(map, row0, col0, row1, col1, row2, col2, row3, col3) and
    isAdjacentFingerBi(map, row1, col1, row2, col2)

# Same Row Adjacent Finger True Roll patterns
proc isSameRowAdjacentFingerTrueRoll(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isTrueRoll(map, row0, col0, row1, col1, row2, col2, row3, col3) and
    isSameRowModBi(map, row1, col1, row2, col2) and
    isAdjacentFingerBi(map, row1, col1, row2, col2)

proc isSameRowAdjacentFingerTrueRollIn(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isTrueRollIn(map, row0, col0, row1, col1, row2, col2, row3, col3) and
    isSameRowModBi(map, row1, col1, row2, col2) and
    isAdjacentFingerBi(map, row1, col1, row2, col2)

proc isSameRowAdjacentFingerTrueRollOut(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isTrueRollOut(map, row0, col0, row1, col1, row2, col2, row3, col3) and
    isSameRowModBi(map, row1, col1, row2, col2) and
    isAdjacentFingerBi(map, row1, col1, row2, col2)

# Chained Roll patterns
proc isChainedRoll(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isRoll(map, row0, col0, row1, col1, row2, col2) and
    isRoll(map, row1, col1, row2, col2, row3, col3) and
    not isSameHandBi(map, row1, col1, row2, col2)

proc isChainedRollIn(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isChainedRoll(map, row0, col0, row1, col1, row2, col2, row3, col3) and
    isRollIn(map, row0, col0, row1, col1, row2, col2) and
    isRollIn(map, row1, col1, row2, col2, row3, col3)

proc isChainedRollOut(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isChainedRoll(map, row0, col0, row1, col1, row2, col2, row3, col3) and
    isRollOut(map, row0, col0, row1, col1, row2, col2) and
    isRollOut(map, row1, col1, row2, col2, row3, col3)

proc isChainedRollMix(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isChainedRoll(map, row0, col0, row1, col1, row2, col2, row3, col3) and (
    (
      isRollIn(map, row0, col0, row1, col1, row2, col2) and
      isRollOut(map, row1, col1, row2, col2, row3, col3)
    ) or (
      isRollOut(map, row0, col0, row1, col1, row2, col2) and
      isRollIn(map, row1, col1, row2, col2, row3, col3)
    )
  )

# Same Row Chained Roll patterns
proc isSameRowChainedRoll(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isChainedRoll(map, row0, col0, row1, col1, row2, col2, row3, col3) and
    isSameRowModBi(map, row0, col0, row1, col1) and
    isSameRowModBi(map, row2, col2, row3, col3)

proc isSameRowChainedRollIn(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isChainedRollIn(map, row0, col0, row1, col1, row2, col2, row3, col3) and
    isSameRowModBi(map, row0, col0, row1, col1) and
    isSameRowModBi(map, row2, col2, row3, col3)

proc isSameRowChainedRollOut(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isChainedRollOut(map, row0, col0, row1, col1, row2, col2, row3, col3) and
    isSameRowModBi(map, row0, col0, row1, col1) and
    isSameRowModBi(map, row2, col2, row3, col3)

proc isSameRowChainedRollMix(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isChainedRollMix(map, row0, col0, row1, col1, row2, col2, row3, col3) and
    isSameRowModBi(map, row0, col0, row1, col1) and
    isSameRowModBi(map, row2, col2, row3, col3)

# Adjacent Finger Chained Roll patterns
proc isAdjacentFingerChainedRoll(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isChainedRoll(map, row0, col0, row1, col1, row2, col2, row3, col3) and
    isAdjacentFingerBi(map, row0, col0, row1, col1) and
    isAdjacentFingerBi(map, row2, col2, row3, col3)

proc isAdjacentFingerChainedRollIn(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isChainedRollIn(map, row0, col0, row1, col1, row2, col2, row3, col3) and
    isAdjacentFingerBi(map, row0, col0, row1, col1) and
    isAdjacentFingerBi(map, row2, col2, row3, col3)

proc isAdjacentFingerChainedRollOut(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isChainedRollOut(map, row0, col0, row1, col1, row2, col2, row3, col3) and
    isAdjacentFingerBi(map, row0, col0, row1, col1) and
    isAdjacentFingerBi(map, row2, col2, row3, col3)

proc isAdjacentFingerChainedRollMix(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isChainedRollMix(map, row0, col0, row1, col1, row2, col2, row3, col3) and
    isAdjacentFingerBi(map, row0, col0, row1, col1) and
    isAdjacentFingerBi(map, row2, col2, row3, col3)

# Same Row Adjacent Finger Chained Roll patterns
proc isSameRowAdjacentFingerChainedRoll(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isChainedRoll(map, row0, col0, row1, col1, row2, col2, row3, col3) and
    isSameRowModBi(map, row0, col0, row1, col1) and
    isSameRowModBi(map, row2, col2, row3, col3) and
    isAdjacentFingerBi(map, row0, col0, row1, col1) and
    isAdjacentFingerBi(map, row2, col2, row3, col3)

proc isSameRowAdjacentFingerChainedRollIn(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isChainedRollIn(map, row0, col0, row1, col1, row2, col2, row3, col3) and
    isSameRowModBi(map, row0, col0, row1, col1) and
    isSameRowModBi(map, row2, col2, row3, col3) and
    isAdjacentFingerBi(map, row0, col0, row1, col1) and
    isAdjacentFingerBi(map, row2, col2, row3, col3)

proc isSameRowAdjacentFingerChainedRollOut(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isChainedRollOut(map, row0, col0, row1, col1, row2, col2, row3, col3) and
    isSameRowModBi(map, row0, col0, row1, col1) and
    isSameRowModBi(map, row2, col2, row3, col3) and
    isAdjacentFingerBi(map, row0, col0, row1, col1) and
    isAdjacentFingerBi(map, row2, col2, row3, col3)

proc isSameRowAdjacentFingerChainedRollMix(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): bool =
  isChainedRollMix(map, row0, col0, row1, col1, row2, col2, row3, col3) and
    isSameRowModBi(map, row0, col0, row1, col1) and
    isSameRowModBi(map, row2, col2, row3, col3) and
    isAdjacentFingerBi(map, row0, col0, row1, col1) and
    isAdjacentFingerBi(map, row2, col2, row3, col3)
