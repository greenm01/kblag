# Basic position checks
proc isSameHandBi(map: FingerMap, row0, col0, row1, col1: uint8): bool =
  let
    f1 = getFinger(map, row0, col0)
    f2 = getFinger(map, row1, col1)
  isSameHand(f1, f2)

proc isSameColBi(row0, col0, row1, col1: uint8): bool =
  col0 == col1

proc isSameRowBi(row0, col0, row1, col1: uint8): bool =
  row0 == row1

proc isSameRowModBi(map: FingerMap, row0, col0, row1, col1: uint8): bool =
  row0 == row1 and not isStretch(map, row0, col0) and not isStretch(map, row1, col1)

proc isSamePosBi(row0, col0, row1, col1: uint8): bool =
  isSameColBi(row0, col0, row1, col1) and isSameRowBi(row0, col0, row1, col1)

proc isAdjacentFingerBi(map: FingerMap, row0, col0, row1, col1: uint8): bool =
  let
    f1 = getFinger(map, row0, col0)
    f2 = getFinger(map, row1, col1)

  not isStretch(map, row0, col0) and not isStretch(map, row1, col1) and
    isAdjacent(map, f1, f2)

proc isSameFingerBi(map: FingerMap, row0, col0, row1, col1: uint8): bool =
  let
    f1 = getFinger(map, row0, col0)
    f2 = getFinger(map, row1, col1)

  f1 == f2 and f1.isSome and not isSamePosBi(row0, col0, row1, col1)

proc isBadSameFingerBi(map: FingerMap, row0, col0, row1, col1: uint8): bool =
  isSameFingerBi(map, row0, col0, row1, col1) and abs(row0.int - row1.int) == 2

proc isRussorFingers(map: FingerMap, row0, col0, row1, col1: uint8): bool =
  let
    f1 = getFinger(map, row0, col0)
    f2 = getFinger(map, row1, col1)

  if f1.isNone or f2.isNone:
    return false

  proc isInvalidPair(f1, f2: Finger): bool =
    (f1 == LP and f2 == LI) or (f1 == LI and f2 == LP) or (f1 == RP and f2 == RI) or
      (f1 == RI and f2 == RP)

  not isSameFingerBi(map, row0, col0, row1, col1) and
    not isSamePosBi(row0, col0, row1, col1) and isSameHand(f1, f2) and
    not isInvalidPair(f1.get, f2.get)

proc isFullRussor(map: FingerMap, row0, col0, row1, col1: uint8): bool =
  abs(row0.int - row1.int) == 2 and isRussorFingers(map, row0, col0, row1, col1)

proc isHalfRussor(map: FingerMap, row0, col0, row1, col1: uint8): bool =
  abs(row0.int - row1.int) == 1 and isRussorFingers(map, row0, col0, row1, col1)

proc isIndexStretchBi(map: FingerMap, row0, col0, row1, col1: uint8): bool =
  let
    f1 = getFinger(map, row0, col0)
    f2 = getFinger(map, row1, col1)

  if f1.isNone or f2.isNone:
    return false

  (f1.get == LM and col1 == 5'u8) or (f2.get == LM and col0 == 5'u8) or
    (f1.get == RM and col1 == 6'u8) or (f2.get == RM and col0 == 6'u8)

proc isPinkyStretchBi(map: FingerMap, row0, col0, row1, col1: uint8): bool =
  let
    f1 = getFinger(map, row0, col0)
    f2 = getFinger(map, row1, col1)

  if f1.isNone or f2.isNone:
    return false

  (f1.get == LR and col1 == 0'u8) or (f2.get == LR and col1 == 0'u8) or
    (f1.get == RR and col1 == 11'u8) or (f2.get == RR and col1 == 11'u8)
