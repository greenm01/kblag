proc isSameFingerSkip(map: FingerMap, skip: int, row0, col0, row1, col1: int): bool =
  let
    f1 = getFinger(map, row0, col0)
    f2 = getFinger(map, row1, col1)

  f1 == f2 and f1.isSome and
  not isSamePosBi(row0, col0, row1, col1)

# Individual finger skipgram patterns
proc isLeftPinkySkip(map: FingerMap, skip: int, row0, col0, row1, col1: int): bool =
  let
    f1 = getFinger(map, row0, col0)
    f2 = getFinger(map, row1, col1)

  if f1.isNone or f2.isNone:
    return false

  (f1.get == LP or f2.get == LP) and
  isSameFingerSkip(map, skip, row0, col0, row1, col1)

proc isLeftRingSkip(map: FingerMap, skip: int, row0, col0, row1, col1: int): bool =
  let
    f1 = getFinger(map, row0, col0)
    f2 = getFinger(map, row1, col1)

  if f1.isNone or f2.isNone:
    return false

  (f1.get == LR or f2.get == LR) and
  isSameFingerSkip(map, skip, row0, col0, row1, col1)

proc isLeftMiddleSkip(map: FingerMap, skip: int, row0, col0, row1, col1: int): bool =
  let
    f1 = getFinger(map, row0, col0)
    f2 = getFinger(map, row1, col1)

  if f1.isNone or f2.isNone:
    return false

  (f1.get == LM or f2.get == LM) and
  isSameFingerSkip(map, skip, row0, col0, row1, col1)

proc isLeftIndexSkip(map: FingerMap, skip: int, row0, col0, row1, col1: int): bool =
  let
    f1 = getFinger(map, row0, col0)
    f2 = getFinger(map, row1, col1)

  if f1.isNone or f2.isNone:
    return false

  (f1.get == LI or f2.get == LI) and
  isSameFingerSkip(map, skip, row0, col0, row1, col1)

proc isRightIndexSkip(map: FingerMap, skip: int, row0, col0, row1, col1: int): bool =
  let
    f1 = getFinger(map, row0, col0)
    f2 = getFinger(map, row1, col1)

  if f1.isNone or f2.isNone:
    return false

  (f1.get == RI or f2.get == RI) and
  isSameFingerSkip(map, skip, row0, col0, row1, col1)

proc isRightMiddleSkip(map: FingerMap, skip: int, row0, col0, row1, col1: int): bool =
  let
    f1 = getFinger(map, row0, col0)
    f2 = getFinger(map, row1, col1)

  if f1.isNone or f2.isNone:
    return false

  (f1.get == RM or f2.get == RM) and
  isSameFingerSkip(map, skip, row0, col0, row1, col1)

proc isRightRingSkip(map: FingerMap, skip: int, row0, col0, row1, col1: int): bool =
  let
    f1 = getFinger(map, row0, col0)
    f2 = getFinger(map, row1, col1)

  if f1.isNone or f2.isNone:
    return false

  (f1.get == RR or f2.get == RR) and
  isSameFingerSkip(map, skip, row0, col0, row1, col1)

proc isRightPinkySkip(map: FingerMap, skip: int, row0, col0, row1, col1: int): bool =
  let
    f1 = getFinger(map, row0, col0)
    f2 = getFinger(map, row1, col1)

  if f1.isNone or f2.isNone:
    return false

  (f1.get == RP or f2.get == RP) and
  isSameFingerSkip(map, skip, row0, col0, row1, col1)

# Bad skipgram patterns
proc isBadSameFingerSkip(map: FingerMap, skip: int, row0, col0, row1, col1: int): bool =
  isSameFingerSkip(map, skip, row0, col0, row1, col1) and
  abs(row0 - row1) == 2

proc isBadLeftPinkySkip(map: FingerMap, skip: int, row0, col0, row1, col1: int): bool =
  isLeftPinkySkip(map, skip, row0, col0, row1, col1) and
  abs(row0 - row1) == 2

proc isBadLeftRingSkip(map: FingerMap, skip: int, row0, col0, row1, col1: int): bool =
  isLeftRingSkip(map, skip, row0, col0, row1, col1) and
  abs(row0 - row1) == 2

proc isBadLeftMiddleSkip(map: FingerMap, skip: int, row0, col0, row1, col1: int): bool =
  isLeftMiddleSkip(map, skip, row0, col0, row1, col1) and
  abs(row0 - row1) == 2

proc isBadLeftIndexSkip(map: FingerMap, skip: int, row0, col0, row1, col1: int): bool =
  isLeftIndexSkip(map, skip, row0, col0, row1, col1) and
  abs(row0 - row1) == 2

proc isBadRightIndexSkip(map: FingerMap, skip: int, row0, col0, row1, col1: int): bool =
  isRightIndexSkip(map, skip, row0, col0, row1, col1) and
  abs(row0 - row1) == 2

proc isBadRightMiddleSkip(map: FingerMap, skip: int, row0, col0, row1, col1: int): bool =
  isRightMiddleSkip(map, skip, row0, col0, row1, col1) and
  abs(row0 - row1) == 2

proc isBadRightRingSkip(map: FingerMap, skip: int, row0, col0, row1, col1: int): bool =
  isRightRingSkip(map, skip, row0, col0, row1, col1) and
  abs(row0 - row1) == 2

proc isBadRightPinkySkip(map: FingerMap, skip: int, row0, col0, row1, col1: int): bool =
  isRightPinkySkip(map, skip, row0, col0, row1, col1) and
  abs(row0 - row1) == 2

# Convenience functions for pattern checking
proc hasFingerSkipPattern(map: FingerMap, skip: int, row0, col0, row1, col1: int): bool =
  isLeftPinkySkip(map, skip, row0, col0, row1, col1) or
  isLeftRingSkip(map, skip, row0, col0, row1, col1) or
  isLeftMiddleSkip(map, skip, row0, col0, row1, col1) or
  isLeftIndexSkip(map, skip, row0, col0, row1, col1) or
  isRightIndexSkip(map, skip, row0, col0, row1, col1) or
  isRightMiddleSkip(map, skip, row0, col0, row1, col1) or
  isRightRingSkip(map, skip, row0, col0, row1, col1) or
  isRightPinkySkip(map, skip, row0, col0, row1, col1)

proc hasBadFingerSkipPattern(map: FingerMap, skip: int, row0, col0, row1, col1: int): bool =
  isBadLeftPinkySkip(map, skip, row0, col0, row1, col1) or
  isBadLeftRingSkip(map, skip, row0, col0, row1, col1) or
  isBadLeftMiddleSkip(map, skip, row0, col0, row1, col1) or
  isBadLeftIndexSkip(map, skip, row0, col0, row1, col1) or
  isBadRightIndexSkip(map, skip, row0, col0, row1, col1) or
  isBadRightMiddleSkip(map, skip, row0, col0, row1, col1) or
  isBadRightRingSkip(map, skip, row0, col0, row1, col1) or
  isBadRightPinkySkip(map, skip, row0, col0, row1, col1)

# Helper function to get all skip patterns for a given position pair
proc getAllSkipPatterns(map: FingerMap, skip: int, row0, col0, row1, col1: int): tuple[
  normal: seq[Finger],
  bad: seq[Finger]
] =
  result.normal = @[]
  result.bad = @[]

  template checkPattern(pattern: untyped, badPattern: untyped, finger: Finger) =
    if pattern(map, skip, row0, col0, row1, col1):
      result.normal.add(finger)
    if badPattern(map, skip, row0, col0, row1, col1):
      result.bad.add(finger)

  checkPattern(isLeftPinkySkip, isBadLeftPinkySkip, LP)
  checkPattern(isLeftRingSkip, isBadLeftRingSkip, LR)
  checkPattern(isLeftMiddleSkip, isBadLeftMiddleSkip, LM)
  checkPattern(isLeftIndexSkip, isBadLeftIndexSkip, LI)
  checkPattern(isRightIndexSkip, isBadRightIndexSkip, RI)
  checkPattern(isRightMiddleSkip, isBadRightMiddleSkip, RM)
  checkPattern(isRightRingSkip, isBadRightRingSkip, RR)
  checkPattern(isRightPinkySkip, isBadRightPinkySkip, RP)
