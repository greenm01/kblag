import options, sets, json, tables

type
  Finger = enum
    LP
    LR
    LM
    LI
    RI
    RM
    RR
    RP

  Hand = enum
    Left
    Right

  FingerAssignment = object
    matrix: array[Row.int, array[Col.int, Option[Finger]]]
    stretches: HashSet[(uint8, uint8)]

  FingerMap = object
    assignments: array[Row.int, array[Col.int, Option[Finger]]]
    adjacentPairs: HashSet[(Finger, Finger)]
    stretches: HashSet[(uint8, uint8)]
    handBalance: TableRef[Hand, float]
    fingerLoads: TableRef[Finger, float]

proc newFingerMap(): FingerMap =
  result = FingerMap(
    adjacentPairs: initHashSet[(Finger, Finger)](),
    stretches: initHashSet[(uint8, uint8)](),
    handBalance: newTable[Hand, float](),
    fingerLoads: newTable[Finger, float](),
  )

proc initDefaultFingerMap(): FingerMap =
  result = newFingerMap()

  # Default adjacent finger pairs
  result.adjacentPairs.incl((LP, LR))
  result.adjacentPairs.incl((LR, LM))
  result.adjacentPairs.incl((LM, LI))
  result.adjacentPairs.incl((RI, RM))
  result.adjacentPairs.incl((RM, RR))
  result.adjacentPairs.incl((RR, RP))

  # Default stretches - only top row
  # Left hand stretches
  result.stretches.incl((0'u8, 0'u8)) # Top row leftmost pinky
  result.stretches.incl((0'u8, 5'u8)) # Top row inner left (index)

  # Right hand stretches
  result.stretches.incl((0'u8, 6'u8)) # Top row inner right (index)
  result.stretches.incl((0'u8, 11'u8)) # Top row rightmost pinky

proc getHand(f: Option[Finger]): Option[Hand] =
  if f.isNone:
    none(Hand)
  else:
    case f.get
    of LP .. LI:
      some(Left)
    of RI .. RP:
      some(Right)

proc isSameHand(f1, f2: Option[Finger]): bool =
  if f1.isNone or f2.isNone:
    return false
  getHand(f1).get == getHand(f2).get

proc getFinger(map: FingerMap, row, col: uint8): Option[Finger] =
  if row < 0 or row >= Row or col < 0 or col >= Col:
    none(Finger)
  else:
    map.assignments[row][col]

proc isAdjacent(map: FingerMap, f1, f2: Option[Finger]): bool =
  if f1.isNone or f2.isNone:
    return false

  (f1.get, f2.get) in map.adjacentPairs or (f2.get, f1.get) in map.adjacentPairs

proc isStretch(map: FingerMap, row, col: uint8): bool =
  let f = getFinger(map, row, col)
  if f.isNone: # If no finger assigned, not a stretch
    return false

  return (row, col) in map.stretches

proc validateFingerMap(map: FingerMap): bool =
  # Check matrix dimensions
  if uint8(map.assignments.len) != Row:
    return false

  for row in map.assignments:
    if uint8(row.len) != Col:
      return false

  # Check valid finger assignments
  for row in countup(Row):
    for col in countup(Col):
      if map.assignments[row][col].isSome:
        # No need to check if finger is in Finger enum - it's enforced by the type system
        discard

  # Check valid stretches
  for (row, col) in map.stretches:
    if row < 0 or row >= Row or col < 0 or col >= Col:
      return false

  # Check valid adjacent pairs
  for (f1, f2) in map.adjacentPairs:
    # No need to check if fingers are in Finger enum - it's enforced by the type system
    discard

  true

# Helper functions specific to FingerMap
proc getFingerPair(
    map: FingerMap, row0, col0, row1, col1: uint8
): tuple[f1, f2: Option[Finger]] =
  result.f1 = getFinger(map, row0, col0)
  result.f2 = getFinger(map, row1, col1)

proc getFingerTriple(
    map: FingerMap, row0, col0, row1, col1, row2, col2: uint8
): tuple[f1, f2, f3: Option[Finger]] =
  result.f1 = getFinger(map, row0, col0)
  result.f2 = getFinger(map, row1, col1)
  result.f3 = getFinger(map, row2, col2)

proc getFingerQuad(
    map: FingerMap, row0, col0, row1, col1, row2, col2, row3, col3: uint8
): tuple[f1, f2, f3, f4: Option[Finger]] =
  result.f1 = getFinger(map, row0, col0)
  result.f2 = getFinger(map, row1, col1)
  result.f3 = getFinger(map, row2, col2)
  result.f4 = getFinger(map, row3, col3)

# validation utilities for row and column indices
proc isValidPos(row, col: uint8): bool =
  row >= 0 and row < Row and col >= 0 and col < Col

proc validatePos(row, col: uint8) =
  if not isValidPos(row, col):
    raise newException(ValueError, "Invalid position: row=" & $row & ", col=" & $col)

# helper functions for the new finger-based system
proc isPinky(f: Option[Finger]): bool =
  if f.isNone:
    false
  else:
    f.get in {LP, RP}

proc isIndex(f: Option[Finger]): bool =
  if f.isNone:
    false
  else:
    f.get in {LI, RI}

proc isMiddle(f: Option[Finger]): bool =
  if f.isNone:
    false
  else:
    f.get in {LM, RM}

proc isRing(f: Option[Finger]): bool =
  if f.isNone:
    false
  else:
    f.get in {LR, RR}

proc fingerType(f: Option[Finger]): string =
  if f.isNone:
    "none"
  elif isPinky(f):
    "pinky"
  elif isRing(f):
    "ring"
  elif isMiddle(f):
    "middle"
  elif isIndex(f):
    "index"
  else:
    "unknown"
