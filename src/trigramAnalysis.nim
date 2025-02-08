# Basic pattern checks
proc isSameHandTri(map: FingerMap, row0, col0, row1, col1, row2, col2: int): bool =
  let
    f1 = getFinger(map, row0, col0)
    f2 = getFinger(map, row1, col1)
    f3 = getFinger(map, row2, col2)
  isSameHand(f1, f2) and isSameHand(f2, f3)

proc isSameColTri(row0, col0, row1, col1, row2, col2: int): bool =
  col0 == col1 and col1 == col2

proc isSameRowTri(row0, col0, row1, col1, row2, col2: int): bool =
  row0 == row1 and row1 == row2

proc isSameRowModTri(map: FingerMap, row0, col0, row1, col1, row2, col2: int): bool =
  row0 == row1 and row1 == row2 and
  not isStretch(map, row0, col0) and
  not isStretch(map, row1, col1) and
  not isStretch(map, row2, col2)

proc isSamePosTri(row0, col0, row1, col1, row2, col2: int): bool =
  isSameColTri(row0, col0, row1, col1, row2, col2) and
  isSameRowTri(row0, col0, row1, col1, row2, col2)

proc isAdjacentFingerTri(map: FingerMap, row0, col0, row1, col1, row2, col2: int): bool =
  let
    f1 = getFinger(map, row0, col0)
    f2 = getFinger(map, row1, col1)
    f3 = getFinger(map, row2, col2)

  if f1.isNone or f2.isNone or f3.isNone:
    return false

  not isStretch(map, row0, col0) and
  not isStretch(map, row1, col1) and
  not isStretch(map, row2, col2) and
  isAdjacent(map, f1, f2) and
  isAdjacent(map, f2, f3) and
  f1 != f2 and f2 != f3 and f1 != f3

proc isSameFingerTri(map: FingerMap, row0, col0, row1, col1, row2, col2: int): bool =
  let
    f1 = getFinger(map, row0, col0)
    f2 = getFinger(map, row1, col1)
    f3 = getFinger(map, row2, col2)

  f1 == f2 and f2 == f3 and f1.isSome and
  not isSamePosBi(row0, col0, row1, col1) and
  not isSamePosBi(row1, col1, row2, col2)

proc isRedirect(map: FingerMap, row0, col0, row1, col1, row2, col2: int): bool =
  let
    f1 = getFinger(map, row0, col0)
    f2 = getFinger(map, row1, col1)
    f3 = getFinger(map, row2, col2)

  if f1.isNone or f2.isNone or f3.isNone:
    return false

  isSameHandTri(map, row0, col0, row1, col1, row2, col2) and
  not isSameFingerBi(map, row0, col0, row2, col2) and
  not isSamePosBi(row0, col0, row2, col2) and
  ((ord(f1.get) < ord(f2.get) and ord(f2.get) > ord(f3.get)) or
   (ord(f1.get) > ord(f2.get) and ord(f2.get) < ord(f3.get)))

proc isBadRedirect(map: FingerMap, row0, col0, row1, col1, row2, col2: int): bool =
  let
    f1 = getFinger(map, row0, col0)
    f2 = getFinger(map, row1, col1)
    f3 = getFinger(map, row2, col2)

  if f1.isNone or f2.isNone or f3.isNone:
    return false

  isRedirect(map, row0, col0, row1, col1, row2, col2) and
  f1.get notin {LI, RI} and
  f2.get notin {LI, RI} and
  f3.get notin {LI, RI}

# Alternation patterns
proc isAlt(map: FingerMap, row0, col0, row1, col1, row2, col2: int): bool =
  not isSameHandBi(map, row0, col0, row1, col1) and
  not isSameHandBi(map, row1, col1, row2, col2) and
  not isSameFingerBi(map, row0, col0, row2, col2) and
  not isSamePosBi(row0, col0, row2, col2)

proc isRoll(map: FingerMap, row0, col0, row1, col1, row2, col2: int): bool =
  (isSameHandBi(map, row0, col0, row1, col1) and
    not isSameHandBi(map, row1, col1, row2, col2) and
    not isSameFingerBi(map, row0, col0, row1, col1) and
    not isSamePosBi(row0, col0, row1, col1)) or
  (not isSameHandBi(map, row0, col0, row1, col1) and
    isSameHandBi(map, row1, col1, row2, col2) and
    not isSameFingerBi(map, row1, col1, row2, col2) and
    not isSamePosBi(row1, col1, row2, col2))

proc isRollIn(map: FingerMap, row0, col0, row1, col1, row2, col2: int): bool =
  let
    f1 = getFinger(map, row0, col0)
    f2 = getFinger(map, row1, col1)
    f3 = getFinger(map, row2, col2)

  if f1.isNone or f2.isNone or f3.isNone:
    return false

  isRoll(map, row0, col0, row1, col1, row2, col2) and
  ((isSameHandBi(map, row0, col0, row1, col1) and
    getHand(f1) == some(Left) and
    ord(f1.get) < ord(f2.get)) or
    (isSameHandBi(map, row1, col1, row2, col2) and
    getHand(f2) == some(Left) and
    ord(f2.get) < ord(f3.get)) or
    (isSameHandBi(map, row0, col0, row1, col1) and
    getHand(f1) == some(Right) and
    ord(f1.get) > ord(f2.get)) or
    (isSameHandBi(map, row1, col1, row2, col2) and
    getHand(f2) == some(Right) and
    ord(f2.get) > ord(f3.get)))

proc isAltIn(map: FingerMap, row0, col0, row1, col1, row2, col2: int): bool =
  isAlt(map, row0, col0, row1, col1, row2, col2) and
  isRollIn(map, row0, col0, row2, col2, row1, col1)

proc isAltOut(map: FingerMap, row0, col0, row1, col1, row2, col2: int): bool =
  isAlt(map, row0, col0, row1, col1, row2, col2) and
  not isAltIn(map, row0, col0, row1, col1, row2, col2)

# Same Row patterns
proc isSameRowAlt(map: FingerMap, row0, col0, row1, col1, row2, col2: int): bool =
  isAlt(map, row0, col0, row1, col1, row2, col2) and
  isSameRowBi(row0, col0, row2, col2)

proc isSameRowAltIn(map: FingerMap, row0, col0, row1, col1, row2, col2: int): bool =
  isSameRowAlt(map, row0, col0, row1, col1, row2, col2) and
  isRollIn(map, row0, col0, row2, col2, row1, col1)

proc isSameRowAltOut(map: FingerMap, row0, col0, row1, col1, row2, col2: int): bool =
  isSameRowAlt(map, row0, col0, row1, col1, row2, col2) and
  not isSameRowAltIn(map, row0, col0, row1, col1, row2, col2)

# Adjacent Finger patterns
proc isAdjacentFingerAlt(map: FingerMap, row0, col0, row1, col1, row2, col2: int): bool =
  isAlt(map, row0, col0, row1, col1, row2, col2) and
  isAdjacentFingerBi(map, row0, col0, row2, col2)

proc isAdjacentFingerAltIn(map: FingerMap, row0, col0, row1, col1, row2, col2: int): bool =
  isAdjacentFingerAlt(map, row0, col0, row1, col1, row2, col2) and
  isRollIn(map, row0, col0, row2, col2, row1, col1)

proc isAdjacentFingerAltOut(map: FingerMap, row0, col0, row1, col1, row2, col2: int): bool =
  isAdjacentFingerAlt(map, row0, col0, row1, col1, row2, col2) and
  not isAdjacentFingerAltIn(map, row0, col0, row1, col1, row2, col2)

# Same Row Adjacent Finger patterns
proc isSameRowAdjacentFingerAlt(map: FingerMap, row0, col0, row1, col1, row2, col2: int): bool =
  isAlt(map, row0, col0, row1, col1, row2, col2) and
  isSameRowBi(row0, col0, row2, col2) and
  isAdjacentFingerBi(map, row0, col0, row2, col2)

proc isSameRowAdjacentFingerAltIn(map: FingerMap, row0, col0, row1, col1, row2, col2: int): bool =
  isSameRowAdjacentFingerAlt(map, row0, col0, row1, col1, row2, col2) and
  isRollIn(map, row0, col0, row2, col2, row1, col1)

proc isSameRowAdjacentFingerAltOut(map: FingerMap, row0, col0, row1, col1, row2, col2: int): bool =
  isSameRowAdjacentFingerAlt(map, row0, col0, row1, col1, row2, col2) and
  not isSameRowAdjacentFingerAltIn(map, row0, col0, row1, col1, row2, col2)

# One Hand patterns
proc isOneHand(map: FingerMap, row0, col0, row1, col1, row2, col2: int): bool =
  let
    f1 = getFinger(map, row0, col0)
    f2 = getFinger(map, row1, col1)
    f3 = getFinger(map, row2, col2)

  if f1.isNone or f2.isNone or f3.isNone:
    return false

  isSameHandTri(map, row0, col0, row1, col1, row2, col2) and
  ((ord(f1.get) < ord(f2.get) and ord(f2.get) < ord(f3.get)) or
    (ord(f1.get) > ord(f2.get) and ord(f2.get) > ord(f3.get)))

proc isOneHandIn(map: FingerMap, row0, col0, row1, col1, row2, col2: int): bool =
  let
    f1 = getFinger(map, row0, col0)
    f2 = getFinger(map, row1, col1)
    f3 = getFinger(map, row2, col2)

  if f1.isNone or f2.isNone or f3.isNone:
    return false

  isOneHand(map, row0, col0, row1, col1, row2, col2) and
  ((getHand(f1) == some(Left) and
    ord(f1.get) < ord(f2.get) and ord(f2.get) < ord(f3.get)) or
    (getHand(f1) == some(Right) and
    ord(f1.get) > ord(f2.get) and ord(f2.get) > ord(f3.get)))

proc isOneHandOut(map: FingerMap, row0, col0, row1, col1, row2, col2: int): bool =
  isOneHand(map, row0, col0, row1, col1, row2, col2) and
  not isOneHandIn(map, row0, col0, row1, col1, row2, col2)

# Same Row One Hand patterns
proc isSameRowOneHand(map: FingerMap, row0, col0, row1, col1, row2, col2: int): bool =
  isOneHand(map, row0, col0, row1, col1, row2, col2) and
  isSameRowModTri(map, row0, col0, row1, col1, row2, col2)

proc isSameRowOneHandIn(map: FingerMap, row0, col0, row1, col1, row2, col2: int): bool =
  isOneHandIn(map, row0, col0, row1, col1, row2, col2) and
  isSameRowModTri(map, row0, col0, row1, col1, row2, col2)

proc isSameRowOneHandOut(map: FingerMap, row0, col0, row1, col1, row2, col2: int): bool =
  isOneHandOut(map, row0, col0, row1, col1, row2, col2) and
  isSameRowModTri(map, row0, col0, row1, col1, row2, col2)

# Adjacent Finger One Hand patterns
proc isAdjacentFingerOneHand(map: FingerMap, row0, col0, row1, col1, row2, col2: int): bool =
  isOneHand(map, row0, col0, row1, col1, row2, col2) and
  isAdjacentFingerTri(map, row0, col0, row1, col1, row2, col2)

proc isAdjacentFingerOneHandIn(map: FingerMap, row0, col0, row1, col1, row2, col2: int): bool =
  isOneHandIn(map, row0, col0, row1, col1, row2, col2) and
  isAdjacentFingerTri(map, row0, col0, row1, col1, row2, col2)

proc isAdjacentFingerOneHandOut(map: FingerMap, row0, col0, row1, col1, row2, col2: int): bool =
  isOneHandOut(map, row0, col0, row1, col1, row2, col2) and
  isAdjacentFingerTri(map, row0, col0, row1, col1, row2, col2)

# Same Row Adjacent Finger One Hand patterns
proc isSameRowAdjacentFingerOneHand(map: FingerMap, row0, col0, row1, col1, row2, col2: int): bool =
  isOneHand(map, row0, col0, row1, col1, row2, col2) and
  isSameRowModTri(map, row0, col0, row1, col1, row2, col2) and
  isAdjacentFingerTri(map, row0, col0, row1, col1, row2, col2)

proc isSameRowAdjacentFingerOneHandIn(map: FingerMap, row0, col0, row1, col1, row2, col2: int): bool =
  isOneHandIn(map, row0, col0, row1, col1, row2, col2) and
  isSameRowModTri(map, row0, col0, row1, col1, row2, col2) and
  isAdjacentFingerTri(map, row0, col0, row1, col1, row2, col2)

proc isSameRowAdjacentFingerOneHandOut(map: FingerMap, row0, col0, row1, col1, row2, col2: int): bool =
  isOneHandOut(map, row0, col0, row1, col1, row2, col2) and
  isSameRowModTri(map, row0, col0, row1, col1, row2, col2) and
  isAdjacentFingerTri(map, row0, col0, row1, col1, row2, col2)

# Roll patterns
proc isRollOut(map: FingerMap, row0, col0, row1, col1, row2, col2: int): bool =
  isRoll(map, row0, col0, row1, col1, row2, col2) and
  not isRollIn(map, row0, col0, row1, col1, row2, col2)

proc isSameRowRoll(map: FingerMap, row0, col0, row1, col1, row2, col2: int): bool =
  isRoll(map, row0, col0, row1, col1, row2, col2) and
  ((isSameHandBi(map, row0, col0, row1, col1) and
    isSameRowModBi(map, row0, col0, row1, col1)) or
    (isSameHandBi(map, row1, col1, row2, col2) and
    isSameRowModBi(map, row1, col1, row2, col2)))

proc isSameRowRollIn(map: FingerMap, row0, col0, row1, col1, row2, col2: int): bool =
  isRollIn(map, row0, col0, row1, col1, row2, col2) and
  isSameRowRoll(map, row0, col0, row1, col1, row2, col2)

proc isSameRowRollOut(map: FingerMap, row0, col0, row1, col1, row2, col2: int): bool =
  isRollOut(map, row0, col0, row1, col1, row2, col2) and
  isSameRowRoll(map, row0, col0, row1, col1, row2, col2)

# Adjacent Finger Roll patterns
proc isAdjacentFingerRoll(map: FingerMap, row0, col0, row1, col1, row2, col2: int): bool =
  isRoll(map, row0, col0, row1, col1, row2, col2) and
  isAdjacentFingerBi(map, row0, col0, row1, col1)

proc isAdjacentFingerRollIn(map: FingerMap, row0, col0, row1, col1, row2, col2: int): bool =
  isRollIn(map, row0, col0, row1, col1, row2, col2) and
  isAdjacentFingerRoll(map, row0, col0, row1, col1, row2, col2)

proc isAdjacentFingerRollOut(map: FingerMap, row0, col0, row1, col1, row2, col2: int): bool =
  isRollOut(map, row0, col0, row1, col1, row2, col2) and
  isAdjacentFingerRoll(map, row0, col0, row1, col1, row2, col2)

# Same Row Adjacent Finger Roll patterns
proc isSameRowAdjacentFingerRoll(map: FingerMap, row0, col0, row1, col1, row2, col2: int): bool =
  isSameRowRoll(map, row0, col0, row1, col1, row2, col2) and
  isAdjacentFingerRoll(map, row0, col0, row1, col1, row2, col2)

proc isSameRowAdjacentFingerRollIn(map: FingerMap, row0, col0, row1, col1, row2, col2: int): bool =
  isRollIn(map, row0, col0, row1, col1, row2, col2) and
  isSameRowAdjacentFingerRoll(map, row0, col0, row1, col1, row2, col2)

proc isSameRowAdjacentFingerRollOut(map: FingerMap, row0, col0, row1, col1, row2, col2: int): bool =
  isRollOut(map, row0, col0, row1, col1, row2, col2) and
  isSameRowAdjacentFingerRoll(map, row0, col0, row1, col1, row2, col2)
