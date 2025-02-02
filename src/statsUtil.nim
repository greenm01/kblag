#[ TODO: Load from config file
import json

# Example JSON config file content:
# {
#   "rows": 3,
#   "cols": 12,
#   "fingerAssignment": [
#     ["leftPinky", "leftPinky", "leftRing", ...],
#     ["leftPinky", "leftPinky", "leftRing", ...],
#     ["leftPinky", "leftRing", "leftMiddle", ...]
#   ]
# }

let config = parseFile("config.json")
let rows = config["rows"].getInt()
let cols = config["cols"].getInt()
let fingerAssignment = config["fingerAssignment"].getElems().mapIt(it.mapIt(parseEnum[Finger](it.getStr())))

type
  Finger = enum
    leftPinky = 0,
    leftRing = 1,
    leftMiddle = 2,
    leftIndex = 3,
    rightIndex = 4,
    rightMiddle = 5,
    rightRing = 6,
    rightPinky = 7,

  Hand = enum
    leftHand,
    rightHand

# Lookup table for finger assignments
const FingerAssignment: array[Row, array[Col, Finger]] = [
  # Row 0 (Top row)
  [leftPinky, leftPinky, leftRing, leftMiddle, leftIndex, leftIndex,
   rightIndex, rightIndex, rightMiddle, rightRing, rightPinky, rightPinky],

  # Row 1 (Home row)
  [leftPinky, leftPinky, leftRing, leftMiddle, leftIndex, leftIndex,
   rightIndex, rightIndex, rightMiddle, rightRing, rightPinky, rightPinky],

  #[ Row 2 (Bottom row) - Anglemod
  [leftPinky, leftRing, leftMiddle, leftIndex, leftIndex, leftIndex,
   rightIndex, rightIndex, rightMiddle, rightRing, rightPinky, rightPinky] ]#

  # Row 3 (Bottom row) - Standard
  [leftPinky, leftPinky, leftRing, leftMiddle, leftIndex, leftIndex,
   rightIndex, rightIndex, rightMiddle, rightRing, rightPinky, rightPinky],
    
]

proc finger(row0: int, col0: int): Finger =
  ## Returns the finger assigned to the given row and column.
  if row0 < 0 or row0 >= Row or col0 < 0 or col0 >= Col:
    raise newException(ValueError,
      "Invalid matrix position: row=" & $row0 & ", col=" & $col0 &
      " (expected row in 0.." & $(Row-1) & ", col in 0.." & $(Col-1) & ")")
  return FingerAssignment[row0][col0]

]#

type
  Hand = enum
    leftHand, rightHand

  Finger = range[0..7]  # Or could be an enum if you prefer

func hand(row0, col0: int): char =
  if col0 < Col div 2: 'l'
  else: 'r'

func getHand(row0, col0: int): Hand = 
  if col0 < Col div 2: leftHand
  else: rightHand

func finger(row0, col0: int): int =
  case col0
  of 0, 1: 0
  of 2: 1
  of 3: 2
  of 4, 5: 3
  of 6, 7: 4
  of 8: 5
  of 9: 6
  of 10, 11: 7
  else: 0

proc isStretch(row0, col0: int): int =
  return (if col0 == 0 or col0 == 5 or col0 == 6 or col0 == 11: 1 else: 0)

proc rowDiff(row0, col0, row1, col1: int): int =
  if row0 - row1 < 0: row1 - row0
  else: row0 - row1

# Bi functions
proc isSameHandBi(row0, col0, row1, col1: int): int =
  return (if hand(row0, col0) == hand(row1, col1): 1 else: 0)

proc isSameColBi(row0, col0, row1, col1: int): int =
  return (if col0 == col1: 1 else: 0)

proc isSameRowBi(row0, col0, row1, col1: int): int =
  return (if row0 == row1: 1 else: 0)

proc isSameRowModBi(row0, col0, row1, col1: int): int =
  return (if row0 == row1 and
             isStretch(row0, col0) == 0 and
             isStretch(row1, col1) == 0: 1 else: 0)

proc isSamePosBi(row0, col0, row1, col1: int): int =
  return (if isSameColBi(row0, col0, row1, col1) == 1 and
             isSameRowBi(row0, col0, row1, col1) == 1: 1 else: 0)

proc isAdjacentFingerBi(row0, col0, row1, col1: int): int =
  return (if isStretch(row0, col0) == 0 and 
             isStretch(row1, col1) == 0 and
             (finger(row0, col0) - finger(row1, col1) == 1 or
              finger(row0, col0) - finger(row1, col1) == -1): 1 else: 0)

proc isSameFingerBi(row0, col0, row1, col1: int): int =
  return (if finger(row0, col0) == finger(row1, col1) and
             isSamePosBi(row0, col0, row1, col1) == 0: 1 else: 0)

proc isBadSameFingerBi(row0, col0, row1, col1: int): int =
  return (if isSameFingerBi(row0, col0, row1, col1) == 1 and 
             (row0 - row1 == 2 or row1 - row0 == 2): 1 else: 0)

proc isRussorFingers(row0, col0, row1, col1: int): int =
  return (if isSameFingerBi(row0, col0, row1, col1) == 0 and
             isSamePosBi(row0, col0, row1, col1) == 0 and
             isSameHandBi(row0, col0, row1, col1) == 1 and
             not (finger(row0, col0) == 0 and finger(row1, col1) == 3) and
             not (finger(row0, col0) == 3 and finger(row1, col1) == 0) and
             not (finger(row0, col0) == 4 and finger(row1, col1) == 7) and
             not (finger(row0, col0) == 7 and finger(row1, col1) == 4): 1 else: 0)

proc isFullRussor(row0, col0, row1, col1: int): int =
  return (if rowDiff(row0, col0, row1, col1) == 2 and
             isRussorFingers(row0, col0, row1, col1) == 1: 1 else: 0)

proc isHalfRussor(row0, col0, row1, col1: int): int =
  return (if rowDiff(row0, col0, row1, col1) == 1 and
             isRussorFingers(row0, col0, row1, col1) == 1: 1 else: 0)

proc isIndexStretchBi(row0, col0, row1, col1: int): int =
  return (if (finger(row0, col0) == 2 and col1 == 5) or
             (finger(row1, col1) == 2 and col0 == 5) or
             (finger(row0, col0) == 5 and col1 == 6) or
             (finger(row1, col1) == 5 and col0 == 6): 1 else: 0)

proc isPinkyStretchBi(row0, col0, row1, col1: int): int =
  return (if (finger(row0, col0) == 1 and col1 == 0) or
             (finger(row1, col1) == 1 and col0 == 0) or
             (finger(row0, col0) == 6 and col1 == 11) or
             (finger(row1, col1) == 6 and col0 == 11): 1 else: 0)

# Tri functions
proc isSameHandTri(row0, col0, row1, col1, row2, col2: int): int =
  return (if hand(row0, col0) == hand(row1, col1) and
             hand(row1, col1) == hand(row2, col2): 1 else: 0)

proc isSameColTri(row0, col0, row1, col1, row2, col2: int): int =
  return (if col0 == col1 and col1 == col2: 1 else: 0)

proc isSameRowTri(row0, col0, row1, col1, row2, col2: int): int =
  return (if row0 == row1 and row1 == row2: 1 else: 0)

proc isSameRowModTri(row0, col0, row1, col1, row2, col2: int): int =
  return (if row0 == row1 and row1 == row2 and
             isStretch(row0, col0) == 0 and
             isStretch(row1, col1) == 0 and
             isStretch(row2, col2) == 0: 1 else: 0)

proc isSamePosTri(row0, col0, row1, col1, row2, col2: int): int =
  return (if isSameColTri(row0, col0, row1, col1, row2, col2) == 1 and
             isSameRowTri(row0, col0, row1, col1, row2, col2) == 1: 1 else: 0)

proc isAdjacentFingerTri(row0, col0, row1, col1, row2, col2: int): int =
  return (if isStretch(row0, col0) == 0 and 
             isStretch(row1, col1) == 0 and 
             isStretch(row2, col2) == 0 and
             (finger(row0, col0) - finger(row1, col1) == 1 or
              finger(row0, col0) - finger(row1, col1) == -1) and
             (finger(row1, col1) - finger(row2, col2) == 1 or
              finger(row1, col1) - finger(row2, col2) == -1) and
             finger(row0, col0) != finger(row1, col1) and
             finger(row1, col1) != finger(row2, col2) and
             finger(row0, col0) != finger(row2, col2): 1 else: 0)

proc isSameFingerTri(row0, col0, row1, col1, row2, col2: int): int =
  return (if finger(row0, col0) == finger(row1, col1) and
             finger(row1, col1) == finger(row2, col2) and
             isSamePosBi(row0, col0, row1, col1) == 0 and
             isSamePosBi(row1, col1, row2, col2) == 0: 1 else: 0)

proc isRedirect(row0, col0, row1, col1, row2, col2: int): int =
  return (if isSameHandTri(row0, col0, row1, col1, row2, col2) == 1 and
             isSameFingerBi(row0, col0, row2, col2) == 0 and
             isSamePosBi(row0, col0, row2, col2) == 0 and
             ((finger(row0, col0) < finger(row1, col1) and
               finger(row1, col1) > finger(row2, col2)) or
              (finger(row0, col0) > finger(row1, col1) and
               finger(row1, col1) < finger(row2, col2))): 1 else: 0)

proc isBadRedirect(row0, col0, row1, col1, row2, col2: int): int =
  return (if isRedirect(row0, col0, row1, col1, row2, col2) == 1 and
             finger(row0, col0) != 3 and finger(row0, col0) != 4 and
             finger(row1, col1) != 3 and finger(row1, col1) != 4 and
             finger(row2, col2) != 3 and finger(row2, col2) != 4: 1 else: 0)

proc isAlt(row0, col0, row1, col1, row2, col2: int): int =
  return (if isSameHandBi(row0, col0, row1, col1) == 0 and
             isSameHandBi(row1, col1, row2, col2) == 0 and
             isSameFingerBi(row0, col0, row2, col2) == 0 and
             isSamePosBi(row0, col0, row2, col2) == 0: 1 else: 0)

proc isRoll(row0, col0, row1, col1, row2, col2: int): int =
  return (if (isSameHandBi(row0, col0, row1, col1) == 1 and
              isSameHandBi(row1, col1, row2, col2) == 0 and
              isSameFingerBi(row0, col0, row1, col1) == 0 and
              isSamePosBi(row0, col0, row1, col1) == 0) or
             (isSameHandBi(row0, col0, row1, col1) == 0 and
              isSameHandBi(row1, col1, row2, col2) == 1 and
              isSameFingerBi(row1, col1, row2, col2) == 0 and
              isSamePosBi(row1, col1, row2, col2) == 0): 1 else: 0)

proc isRollIn(row0, col0, row1, col1, row2, col2: int): int =
  return (if isRoll(row0, col0, row1, col1, row2, col2) == 1 and
             ((isSameHandBi(row0, col0, row1, col1) == 1 and 
               hand(row1, col1) == 'l' and
               finger(row0, col0) < finger(row1, col1)) or
              (isSameHandBi(row1, col1, row2, col2) == 1 and 
               hand(row1, col1) == 'l' and
               finger(row1, col1) < finger(row2, col2)) or
              (isSameHandBi(row0, col0, row1, col1) == 1 and 
               hand(row1, col1) == 'r' and
               finger(row0, col0) > finger(row1, col1)) or
              (isSameHandBi(row1, col1, row2, col2) == 1 and 
               hand(row1, col1) == 'r' and
               finger(row1, col1) > finger(row2, col2))): 1 else: 0)

proc isAltIn(row0, col0, row1, col1, row2, col2: int): int =
  return (if isAlt(row0, col0, row1, col1, row2, col2) == 1 and
             isRollIn(row0, col0, row2, col2, row1, col1) == 1: 1 else: 0)

proc isAltOut(row0, col0, row1, col1, row2, col2: int): int =
  return (if isAlt(row0, col0, row1, col1, row2, col2) == 1 and
             isAltIn(row0, col0, row1, col1, row2, col2) == 0: 1 else: 0)

proc isSameRowAlt(row0, col0, row1, col1, row2, col2: int): int =
  return (if isAlt(row0, col0, row1, col1, row2, col2) == 1 and
             isSameRowBi(row0, col0, row2, col2) == 1: 1 else: 0)

proc isSameRowAltIn(row0, col0, row1, col1, row2, col2: int): int =
  return (if isSameRowAlt(row0, col0, row1, col1, row2, col2) == 1 and
             isRollIn(row0, col0, row2, col2, row1, col1) == 1: 1 else: 0)

proc isSameRowAltOut(row0, col0, row1, col1, row2, col2: int): int =
  return (if isSameRowAlt(row0, col0, row1, col1, row2, col2) == 1 and
             isSameRowAltIn(row0, col0, row1, col1, row2, col2) == 0: 1 else: 0)

proc isAdjacentFingerAlt(row0, col0, row1, col1, row2, col2: int): int =
  return (if isAlt(row0, col0, row1, col1, row2, col2) == 1 and
             isAdjacentFingerBi(row0, col0, row2, col2) == 1: 1 else: 0)

proc isAdjacentFingerAltIn(row0, col0, row1, col1, row2, col2: int): int =
  return (if isAdjacentFingerAlt(row0, col0, row1, col1, row2, col2) == 1 and
             isRollIn(row0, col0, row2, col2, row1, col1) == 1: 1 else: 0)

proc isAdjacentFingerAltOut(row0, col0, row1, col1, row2, col2: int): int =
  return (if isAdjacentFingerAlt(row0, col0, row1, col1, row2, col2) == 1 and
             isAdjacentFingerAltIn(row0, col0, row1, col1, row2, col2) == 0: 1 else: 0)

proc isSameRowAdjacentFingerAlt(row0, col0, row1, col1, row2, col2: int): int =
  return (if isAlt(row0, col0, row1, col1, row2, col2) == 1 and
             isSameRowBi(row0, col0, row2, col2) == 1 and
             isAdjacentFingerBi(row0, col0, row2, col2) == 1: 1 else: 0)

proc isSameRowAdjacentFingerAltIn(row0, col0, row1, col1, row2, col2: int): int =
  return (if isSameRowAdjacentFingerAlt(row0, col0, row1, col1, row2, col2) == 1 and
             isRollIn(row0, col0, row2, col2, row1, col1) == 1: 1 else: 0)

proc isSameRowAdjacentFingerAltOut(row0, col0, row1, col1, row2, col2: int): int =
  return (if isSameRowAdjacentFingerAlt(row0, col0, row1, col1, row2, col2) == 1 and
             isSameRowAdjacentFingerAltIn(row0, col0, row1, col1, row2, col2) == 0: 1 else: 0)

proc isOnehand(row0, col0, row1, col1, row2, col2: int): int =
  return (if isSameHandTri(row0, col0, row1, col1, row2, col2) == 1 and
             ((finger(row0, col0) < finger(row1, col1) and
               finger(row1, col1) < finger(row2, col2)) or
              (finger(row0, col0) > finger(row1, col1) and
               finger(row1, col1) > finger(row2, col2))): 1 else: 0)

proc isOnehandIn(row0, col0, row1, col1, row2, col2: int): int =
  return (if isOnehand(row0, col0, row1, col1, row2, col2) == 1 and
             ((hand(row0, col0) == 'l' and
               finger(row0, col0) < finger(row1, col1) and
               finger(row1, col1) < finger(row2, col2)) or
              (hand(row0, col0) == 'r' and
               finger(row0, col0) > finger(row1, col1) and
               finger(row1, col1) > finger(row2, col2))): 1 else: 0)

proc isOnehandOut(row0, col0, row1, col1, row2, col2: int): int =
  return (if isOnehand(row0, col0, row1, col1, row2, col2) == 1 and
             isOnehandIn(row0, col0, row1, col1, row2, col2) == 0: 1 else: 0)

proc isSameRowOnehand(row0, col0, row1, col1, row2, col2: int): int =
  return (if isOnehand(row0, col0, row1, col1, row2, col2) == 1 and
             isSameRowModTri(row0, col0, row1, col1, row2, col2) == 1: 1 else: 0)

proc isSameRowOnehandIn(row0, col0, row1, col1, row2, col2: int): int =
  return (if isOnehandIn(row0, col0, row1, col1, row2, col2) == 1 and
             isSameRowModTri(row0, col0, row1, col1, row2, col2) == 1: 1 else: 0)

proc isSameRowOnehandOut(row0, col0, row1, col1, row2, col2: int): int =
  return (if isOnehandOut(row0, col0, row1, col1, row2, col2) == 1 and
             isSameRowModTri(row0, col0, row1, col1, row2, col2) == 1: 1 else: 0)

proc isAdjacentFingerOnehand(row0, col0, row1, col1, row2, col2: int): int =
  return (if isOnehand(row0, col0, row1, col1, row2, col2) == 1 and
             isAdjacentFingerTri(row0, col0, row1, col1, row2, col2) == 1: 1 else: 0)

proc isAdjacentFingerOnehandIn(row0, col0, row1, col1, row2, col2: int): int =
  return (if isOnehandIn(row0, col0, row1, col1, row2, col2) == 1 and
             isAdjacentFingerTri(row0, col0, row1, col1, row2, col2) == 1: 1 else: 0)

proc isAdjacentFingerOnehandOut(row0, col0, row1, col1, row2, col2: int): int =
  return (if isOnehandOut(row0, col0, row1, col1, row2, col2) == 1 and
             isAdjacentFingerTri(row0, col0, row1, col1, row2, col2) == 1: 1 else: 0)

proc isSameRowAdjacentFingerOnehand(row0, col0, row1, col1, row2, col2: int): int =
  return (if isOnehand(row0, col0, row1, col1, row2, col2) == 1 and
             isSameRowModTri(row0, col0, row1, col1, row2, col2) == 1 and
             isAdjacentFingerTri(row0, col0, row1, col1, row2, col2) == 1: 1 else: 0)

proc isSameRowAdjacentFingerOnehandIn(row0, col0, row1, col1, row2, col2: int): int =
  return (if isOnehandIn(row0, col0, row1, col1, row2, col2) == 1 and
             isSameRowModTri(row0, col0, row1, col1, row2, col2) == 1 and
             isAdjacentFingerTri(row0, col0, row1, col1, row2, col2) == 1: 1 else: 0)

proc isSameRowAdjacentFingerOnehandOut(row0, col0, row1, col1, row2, col2: int): int =
  return (if isOnehandOut(row0, col0, row1, col1, row2, col2) == 1 and
             isSameRowModTri(row0, col0, row1, col1, row2, col2) == 1 and
             isAdjacentFingerTri(row0, col0, row1, col1, row2, col2) == 1: 1 else: 0)

proc isRollOut(row0, col0, row1, col1, row2, col2: int): int =
  return (if isRoll(row0, col0, row1, col1, row2, col2) == 1 and
             isRollIn(row0, col0, row1, col1, row2, col2) == 0: 1 else: 0)

proc isSameRowRoll(row0, col0, row1, col1, row2, col2: int): int =
  return (if isRoll(row0, col0, row1, col1, row2, col2) == 1 and
             ((isSameHandBi(row0, col0, row1, col1) == 1 and 
               isSameRowModBi(row0, col0, row1, col1) == 1) or
              (isSameHandBi(row1, col1, row2, col2) == 1 and 
               isSameRowModBi(row1, col1, row2, col2) == 1)): 1 else: 0)

proc isSameRowRollIn(row0, col0, row1, col1, row2, col2: int): int =
  return (if isRollIn(row0, col0, row1, col1, row2, col2) == 1 and
             isSameRowRoll(row0, col0, row1, col1, row2, col2) == 1: 1 else: 0)

proc isSameRowRollOut(row0, col0, row1, col1, row2, col2: int): int =
  return (if isRollOut(row0, col0, row1, col1, row2, col2) == 1 and
             isSameRowRoll(row0, col0, row1, col1, row2, col2) == 1: 1 else: 0)

proc isAdjacentFingerRoll(row0, col0, row1, col1, row2, col2: int): int =
  return (if isRoll(row0, col0, row1, col1, row2, col2) == 1 and
             ((isSameHandBi(row0, col0, row1, col1) == 1 and 
               isAdjacentFingerBi(row0, col0, row1, col1) == 1) or
              (isSameHandBi(row1, col1, row2, col2) == 1 and 
               isAdjacentFingerBi(row1, col1, row2, col2) == 1)): 1 else: 0)

proc isAdjacentFingerRollIn(row0, col0, row1, col1, row2, col2: int): int =
  return (if isRollIn(row0, col0, row1, col1, row2, col2) == 1 and
             isAdjacentFingerRoll(row0, col0, row1, col1, row2, col2) == 1: 1 else: 0)

proc isAdjacentFingerRollOut(row0, col0, row1, col1, row2, col2: int): int =
  return (if isRollOut(row0, col0, row1, col1, row2, col2) == 1 and
             isAdjacentFingerRoll(row0, col0, row1, col1, row2, col2) == 1: 1 else: 0)

proc isSameRowAdjacentFingerRoll(row0, col0, row1, col1, row2, col2: int): int =
  return (if isSameRowRoll(row0, col0, row1, col1, row2, col2) == 1 and
             isAdjacentFingerRoll(row0, col0, row1, col1, row2, col2) == 1: 1 else: 0)

proc isSameRowAdjacentFingerRollIn(row0, col0, row1, col1, row2, col2: int): int =
  return (if isRollIn(row0, col0, row1, col1, row2, col2) == 1 and
             isSameRowAdjacentFingerRoll(row0, col0, row1, col1, row2, col2) == 1: 1 else: 0)

proc isSameRowAdjacentFingerRollOut(row0, col0, row1, col1, row2, col2: int): int =
  return (if isRollOut(row0, col0, row1, col1, row2, col2) == 1 and
             isSameRowAdjacentFingerRoll(row0, col0, row1, col1, row2, col2) == 1: 1 else: 0)

# Quad functions
proc isSameHandQuad(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if hand(row0, col0) == hand(row1, col1) and
             hand(row1, col1) == hand(row2, col2) and
             hand(row2, col2) == hand(row3, col3): 1 else: 0)

proc isSameColQuad(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if col0 == col1 and col1 == col2 and col2 == col3: 1 else: 0)

proc isSameRowQuad(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if row0 == row1 and row1 == row2 and row2 == row3: 1 else: 0)

proc isSameRowModQuad(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if row0 == row1 and row1 == row2 and row2 == row3 and
             isStretch(row0, col0) == 0 and isStretch(row1, col1) == 0 and
             isStretch(row2, col2) == 0 and isStretch(row3, col3) == 0: 1 else: 0)

proc isSamePosQuad(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isSameColQuad(row0, col0, row1, col1, row2, col2, row3, col3) == 1 and
             isSameRowQuad(row0, col0, row1, col1, row2, col2, row3, col3) == 1: 1 else: 0)

proc isAdjacentFingerQuad(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isStretch(row0, col0) == 0 and isStretch(row1, col1) == 0 and
             isStretch(row2, col2) == 0 and isStretch(row3, col3) == 0 and
             (finger(row0, col0) - finger(row1, col1) == 1 or
              finger(row0, col0) - finger(row1, col1) == -1) and
             (finger(row1, col1) - finger(row2, col2) == 1 or
              finger(row1, col1) - finger(row2, col2) == -1) and
             (finger(row2, col2) - finger(row3, col3) == 1 or
              finger(row2, col2) - finger(row3, col3) == -1) and
             finger(row0, col0) != finger(row1, col1) and
             finger(row1, col1) != finger(row2, col2) and
             finger(row0, col0) != finger(row2, col2): 1 else: 0)

proc isSameFingerQuad(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if finger(row0, col0) == finger(row1, col1) and
             finger(row1, col1) == finger(row2, col2) and
             finger(row2, col2) == finger(row3, col3) and
             isSamePosBi(row0, col0, row1, col1) == 0 and
             isSamePosBi(row1, col1, row2, col2) == 0 and
             isSamePosBi(row2, col2, row3, col3) == 0: 1 else: 0)

proc isOnehandQuad(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isSameHandQuad(row0, col0, row1, col1, row2, col2, row3, col3) == 1 and
             ((finger(row0, col0) < finger(row1, col1) and
               finger(row1, col1) < finger(row2, col2) and
               finger(row2, col2) < finger(row3, col3)) or
              (finger(row0, col0) > finger(row1, col1) and
               finger(row1, col1) > finger(row2, col2) and
               finger(row2, col2) > finger(row3, col3))): 1 else: 0)

proc isOnehandQuadIn(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isOnehandQuad(row0, col0, row1, col1, row2, col2, row3, col3) == 1 and
             ((hand(row0, col0) == 'l' and
               finger(row0, col0) < finger(row1, col1) and
               finger(row1, col1) < finger(row2, col2) and
               finger(row2, col2) < finger(row3, col3)) or
              (hand(row0, col0) == 'r' and
               finger(row0, col0) > finger(row1, col1) and
               finger(row1, col1) > finger(row2, col2) and
               finger(row2, col2) > finger(row3, col3))): 1 else: 0)

proc isOnehandQuadOut(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isOnehandQuad(row0, col0, row1, col1, row2, col2, row3, col3) == 1 and
             isOnehandQuadIn(row0, col0, row1, col1, row2, col2, row3, col3) == 0: 1 else: 0)

proc isSameRowOnehandQuad(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isOnehandQuad(row0, col0, row1, col1, row2, col2, row3, col3) == 1 and
             isSameRowModQuad(row0, col0, row1, col1, row2, col2, row3, col3) == 1: 1 else: 0)

proc isSameRowOnehandQuadIn(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isOnehandQuadIn(row0, col0, row1, col1, row2, col2, row3, col3) == 1 and
             isSameRowModQuad(row0, col0, row1, col1, row2, col2, row3, col3) == 1: 1 else: 0)

proc isSameRowOnehandQuadOut(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isOnehandQuadOut(row0, col0, row1, col1, row2, col2, row3, col3) == 1 and
             isSameRowModQuad(row0, col0, row1, col1, row2, col2, row3, col3) == 1: 1 else: 0)

proc isAdjacentFingerOnehandQuad(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isOnehandQuad(row0, col0, row1, col1, row2, col2, row3, col3) == 1 and
             isAdjacentFingerQuad(row0, col0, row1, col1, row2, col2, row3, col3) == 1: 1 else: 0)

proc isAdjacentFingerOnehandQuadIn(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isOnehandQuadIn(row0, col0, row1, col1, row2, col2, row3, col3) == 1 and
             isAdjacentFingerQuad(row0, col0, row1, col1, row2, col2, row3, col3) == 1: 1 else: 0)

proc isAdjacentFingerOnehandQuadOut(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isOnehandQuadOut(row0, col0, row1, col1, row2, col2, row3, col3) == 1 and
             isAdjacentFingerQuad(row0, col0, row1, col1, row2, col2, row3, col3) == 1: 1 else: 0)

proc isSameRowAdjacentFingerOnehandQuad(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isOnehandQuad(row0, col0, row1, col1, row2, col2, row3, col3) == 1 and
             isSameRowModQuad(row0, col0, row1, col1, row2, col2, row3, col3) == 1 and
             isAdjacentFingerQuad(row0, col0, row1, col1, row2, col2, row3, col3) == 1: 1 else: 0)

proc isSameRowAdjacentFingerOnehandQuadIn(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isOnehandQuadIn(row0, col0, row1, col1, row2, col2, row3, col3) == 1 and
             isSameRowModQuad(row0, col0, row1, col1, row2, col2, row3, col3) == 1 and
             isAdjacentFingerQuad(row0, col0, row1, col1, row2, col2, row3, col3) == 1: 1 else: 0)

proc isSameRowAdjacentFingerOnehandQuadOut(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isOnehandQuadOut(row0, col0, row1, col1, row2, col2, row3, col3) == 1 and
             isSameRowModQuad(row0, col0, row1, col1, row2, col2, row3, col3) == 1 and
             isAdjacentFingerQuad(row0, col0, row1, col1, row2, col2, row3, col3) == 1: 1 else: 0)

proc isRollQuad(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if (isOnehand(row0, col0, row1, col1, row2, col2) == 1 and
              isSameHandBi(row2, col2, row3, col3) == 0) or
             (isSameHandBi(row0, col0, row1, col1) == 0 and
              isOnehand(row1, col1, row2, col2, row3, col3) == 1): 1 else: 0)

proc isRollQuadIn(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if (isOnehandIn(row0, col0, row1, col1, row2, col2) == 1 and
              isSameHandBi(row2, col2, row3, col3) == 0) or
             (isSameHandBi(row0, col0, row1, col1) == 0 and
              isOnehandIn(row1, col1, row2, col2, row3, col3) == 1): 1 else: 0)

proc isRollQuadOut(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isRollQuad(row0, col0, row1, col1, row2, col2, row3, col3) == 1 and
             isRollQuadIn(row0, col0, row1, col1, row2, col2, row3, col3) == 0: 1 else: 0)

proc isSameRowRollQuad(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isRollQuad(row0, col0, row1, col1, row2, col2, row3, col3) == 1 and
             ((isOnehand(row0, col0, row1, col1, row2, col2) == 1 and
               isSameRowOnehand(row0, col0, row1, col1, row2, col2) == 1) or
              (isOnehand(row1, col1, row2, col2, row3, col3) == 1 and
               isSameRowOnehand(row1, col1, row2, col2, row3, col3) == 1)): 1 else: 0)

proc isSameRowRollQuadIn(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isSameRowRollQuad(row0, col0, row1, col1, row2, col2, row3, col3) == 1 and
             isRollQuadIn(row0, col0, row1, col1, row2, col2, row3, col3) == 1: 1 else: 0)

proc isSameRowRollQuadOut(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isSameRowRollQuad(row0, col0, row1, col1, row2, col2, row3, col3) == 1 and
             isRollQuadOut(row0, col0, row1, col1, row2, col2, row3, col3) == 1: 1 else: 0)

proc isAdjacentFingerRollQuad(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isRollQuad(row0, col0, row1, col1, row2, col2, row3, col3) == 1 and
             ((isOnehand(row0, col0, row1, col1, row2, col2) == 1 and
               isAdjacentFingerOnehand(row0, col0, row1, col1, row2, col2) == 1) or
              (isOnehand(row1, col1, row2, col2, row3, col3) == 1 and
               isAdjacentFingerOnehand(row1, col1, row2, col2, row3, col3) == 1)): 1 else: 0)

proc isAdjacentFingerRollQuadIn(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isAdjacentFingerRollQuad(row0, col0, row1, col1, row2, col2, row3, col3) == 1 and
             isRollQuadIn(row0, col0, row1, col1, row2, col2, row3, col3) == 1: 1 else: 0)

proc isAdjacentFingerRollQuadOut(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isAdjacentFingerRollQuad(row0, col0, row1, col1, row2, col2, row3, col3) == 1 and
             isRollQuadOut(row0, col0, row1, col1, row2, col2, row3, col3) == 1: 1 else: 0)

proc isSameRowAdjacentFingerRollQuad(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isRollQuad(row0, col0, row1, col1, row2, col2, row3, col3) == 1 and
             ((isOnehand(row0, col0, row1, col1, row2, col2) == 1 and
               isSameRowAdjacentFingerOnehand(row0, col0, row1, col1, row2, col2) == 1) or
              (isOnehand(row1, col1, row2, col2, row3, col3) == 1 and
               isSameRowAdjacentFingerOnehand(row1, col1, row2, col2, row3, col3) == 1)): 1 else: 0)

proc isSameRowAdjacentFingerRollQuadIn(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isSameRowAdjacentFingerRollQuad(row0, col0, row1, col1, row2, col2, row3, col3) == 1 and
             isRollQuadIn(row0, col0, row1, col1, row2, col2, row3, col3) == 1: 1 else: 0)

proc isSameRowAdjacentFingerRollQuadOut(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isSameRowAdjacentFingerRollQuad(row0, col0, row1, col1, row2, col2, row3, col3) == 1 and
             isRollQuadOut(row0, col0, row1, col1, row2, col2, row3, col3) == 1: 1 else: 0)

proc isTrueRoll(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isSameHandBi(row0, col0, row1, col1) == 0 and
             isSameHandBi(row1, col1, row2, col2) == 1 and
             isSameHandBi(row2, col2, row3, col3) == 0 and
             isSameFingerBi(row1, col1, row2, col2) == 0 and
             isSamePosBi(row1, col1, row2, col2) == 0: 1 else: 0)

proc isTrueRollIn(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isTrueRoll(row0, col0, row1, col1, row2, col2, row3, col3) == 1 and
             isRollIn(row0, col0, row1, col1, row2, col2) == 1: 1 else: 0)

proc isTrueRollOut(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isTrueRoll(row0, col0, row1, col1, row2, col2, row3, col3) == 1 and
             isRollOut(row0, col0, row1, col1, row2, col2) == 1: 1 else: 0)

proc isSameRowTrueRoll(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isTrueRoll(row0, col0, row1, col1, row2, col2, row3, col3) == 1 and
             isSameRowModBi(row1, col1, row2, col2) == 1: 1 else: 0)

proc isSameRowTrueRollIn(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isTrueRollIn(row0, col0, row1, col1, row2, col2, row3, col3) == 1 and
             isSameRowModBi(row1, col1, row2, col2) == 1: 1 else: 0)

proc isSameRowTrueRollOut(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isTrueRollOut(row0, col0, row1, col1, row2, col2, row3, col3) == 1 and
             isSameRowModBi(row1, col1, row2, col2) == 1: 1 else: 0)

proc isAdjacentFingerTrueRoll(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isTrueRoll(row0, col0, row1, col1, row2, col2, row3, col3) == 1 and
             isAdjacentFingerBi(row1, col1, row2, col2) == 1: 1 else: 0)

proc isAdjacentFingerTrueRollIn(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isTrueRollIn(row0, col0, row1, col1, row2, col2, row3, col3) == 1 and
             isAdjacentFingerBi(row1, col1, row2, col2) == 1: 1 else: 0)

proc isAdjacentFingerTrueRollOut(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isTrueRollOut(row0, col0, row1, col1, row2, col2, row3, col3) == 1 and
             isAdjacentFingerBi(row1, col1, row2, col2) == 1: 1 else: 0)

proc isSameRowAdjacentFingerTrueRoll(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isTrueRoll(row0, col0, row1, col1, row2, col2, row3, col3) == 1 and
             isSameRowModBi(row1, col1, row2, col2) == 1 and
             isAdjacentFingerBi(row1, col1, row2, col2) == 1: 1 else: 0)

proc isSameRowAdjacentFingerTrueRollIn(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isTrueRollIn(row0, col0, row1, col1, row2, col2, row3, col3) == 1 and
             isSameRowModBi(row1, col1, row2, col2) == 1 and
             isAdjacentFingerBi(row1, col1, row2, col2) == 1: 1 else: 0)

proc isSameRowAdjacentFingerTrueRollOut(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isTrueRollOut(row0, col0, row1, col1, row2, col2, row3, col3) == 1 and
             isSameRowModBi(row1, col1, row2, col2) == 1 and
             isAdjacentFingerBi(row1, col1, row2, col2) == 1: 1 else: 0)

proc isChainedRedirect(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isRedirect(row0, col0, row1, col1, row2, col2) == 1 and 
             isRedirect(row1, col1, row2, col2, row3, col3) == 1: 1 else: 0)

proc isBadChainedRedirect(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isBadRedirect(row0, col0, row1, col1, row2, col2) == 1 and 
             isBadRedirect(row1, col1, row2, col2, row3, col3) == 1: 1 else: 0)

proc isChainedAlt(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isAlt(row0, col0, row1, col1, row2, col2) == 1 and 
             isAlt(row1, col1, row2, col2, row3, col3) == 1: 1 else: 0)

proc isChainedAltIn(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isAltIn(row0, col0, row1, col1, row2, col2) == 1 and 
             isAltIn(row1, col1, row2, col2, row3, col3) == 1: 1 else: 0)

proc isChainedAltOut(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isAltOut(row0, col0, row1, col1, row2, col2) == 1 and 
             isAltOut(row1, col1, row2, col2, row3, col3) == 1: 1 else: 0)

proc isChainedAltMix(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if (isAltIn(row0, col0, row1, col1, row2, col2) == 1 and 
              isAltOut(row1, col1, row2, col2, row3, col3) == 1) or
             (isAltOut(row0, col0, row1, col1, row2, col2) == 1 and 
              isAltIn(row1, col1, row2, col2, row3, col3) == 1): 1 else: 0)

proc isChainedSameRowAlt(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isSameRowAlt(row0, col0, row1, col1, row2, col2) == 1 and 
             isSameRowAlt(row1, col1, row2, col2, row3, col3) == 1: 1 else: 0)

proc isChainedSameRowAltIn(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isSameRowAltIn(row0, col0, row1, col1, row2, col2) == 1 and 
             isSameRowAltIn(row1, col1, row2, col2, row3, col3) == 1: 1 else: 0)

proc isChainedSameRowAltOut(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isSameRowAltOut(row0, col0, row1, col1, row2, col2) == 1 and 
             isSameRowAltOut(row1, col1, row2, col2, row3, col3) == 1: 1 else: 0)

proc isChainedSameRowAltMix(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if (isSameRowAltIn(row0, col0, row1, col1, row2, col2) == 1 and 
              isSameRowAltOut(row1, col1, row2, col2, row3, col3) == 1) or
             (isSameRowAltOut(row0, col0, row1, col1, row2, col2) == 1 and 
              isSameRowAltIn(row1, col1, row2, col2, row3, col3) == 1): 1 else: 0)

proc isChainedAdjacentFingerAlt(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isAdjacentFingerAlt(row0, col0, row1, col1, row2, col2) == 1 and 
             isAdjacentFingerAlt(row1, col1, row2, col2, row3, col3) == 1: 1 else: 0)

proc isChainedAdjacentFingerAltIn(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isAdjacentFingerAltIn(row0, col0, row1, col1, row2, col2) == 1 and 
             isAdjacentFingerAltIn(row1, col1, row2, col2, row3, col3) == 1: 1 else: 0)

proc isChainedAdjacentFingerAltOut(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isAdjacentFingerAltOut(row0, col0, row1, col1, row2, col2) == 1 and 
             isAdjacentFingerAltOut(row1, col1, row2, col2, row3, col3) == 1: 1 else: 0)

proc isChainedAdjacentFingerAltMix(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if (isAdjacentFingerAltIn(row0, col0, row1, col1, row2, col2) == 1 and 
              isAdjacentFingerAltOut(row1, col1, row2, col2, row3, col3) == 1) or
             (isAdjacentFingerAltOut(row0, col0, row1, col1, row2, col2) == 1 and 
              isAdjacentFingerAltIn(row1, col1, row2, col2, row3, col3) == 1): 1 else: 0)

proc isChainedSameRowAdjacentFingerAlt(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isSameRowAdjacentFingerAlt(row0, col0, row1, col1, row2, col2) == 1 and 
             isSameRowAdjacentFingerAlt(row1, col1, row2, col2, row3, col3) == 1: 1 else: 0)

proc isChainedSameRowAdjacentFingerAltIn(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isSameRowAdjacentFingerAltIn(row0, col0, row1, col1, row2, col2) == 1 and 
             isSameRowAdjacentFingerAltIn(row1, col1, row2, col2, row3, col3) == 1: 1 else: 0)

proc isChainedSameRowAdjacentFingerAltOut(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isSameRowAdjacentFingerAltOut(row0, col0, row1, col1, row2, col2) == 1 and 
             isSameRowAdjacentFingerAltOut(row1, col1, row2, col2, row3, col3) == 1: 1 else: 0)

proc isChainedSameRowAdjacentFingerAltMix(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if (isSameRowAdjacentFingerAltIn(row0, col0, row1, col1, row2, col2) == 1 and 
              isSameRowAdjacentFingerAltOut(row1, col1, row2, col2, row3, col3) == 1) or
             (isSameRowAdjacentFingerAltOut(row0, col0, row1, col1, row2, col2) == 1 and 
              isSameRowAdjacentFingerAltIn(row1, col1, row2, col2, row3, col3) == 1): 1 else: 0)

proc isChainedRoll(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isRoll(row0, col0, row1, col1, row2, col2) == 1 and 
             isRoll(row1, col1, row2, col2, row3, col3) == 1 and
             isSameHandBi(row1, col1, row2, col2) == 0: 1 else: 0)

proc isChainedRollIn(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isChainedRoll(row0, col0, row1, col1, row2, col2, row3, col3) == 1 and
             isRollIn(row0, col0, row1, col1, row2, col2) == 1 and
             isRollIn(row1, col1, row2, col2, row3, col3) == 1: 1 else: 0)

proc isChainedRollOut(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isChainedRoll(row0, col0, row1, col1, row2, col2, row3, col3) == 1 and
             isRollOut(row0, col0, row1, col1, row2, col2) == 1 and
             isRollOut(row1, col1, row2, col2, row3, col3) == 1: 1 else: 0)

proc isChainedRollMix(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isChainedRoll(row0, col0, row1, col1, row2, col2, row3, col3) == 1 and
             ((isRollIn(row0, col0, row1, col1, row2, col2) == 1 and 
               isRollOut(row1, col1, row2, col2, row3, col3) == 1) or
              (isRollOut(row0, col0, row1, col1, row2, col2) == 1 and 
               isRollIn(row1, col1, row2, col2, row3, col3) == 1)): 1 else: 0)

proc isSameRowChainedRoll(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isChainedRoll(row0, col0, row1, col1, row2, col2, row3, col3) == 1 and
             isSameRowModBi(row0, col0, row1, col1) == 1 and
             isSameRowModBi(row2, col2, row3, col3) == 1: 1 else: 0)

proc isSameRowChainedRollIn(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isChainedRollIn(row0, col0, row1, col1, row2, col2, row3, col3) == 1 and
             isSameRowModBi(row0, col0, row1, col1) == 1 and
             isSameRowModBi(row2, col2, row3, col3) == 1: 1 else: 0)

proc isSameRowChainedRollOut(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isChainedRollOut(row0, col0, row1, col1, row2, col2, row3, col3) == 1 and
             isSameRowModBi(row0, col0, row1, col1) == 1 and
             isSameRowModBi(row2, col2, row3, col3) == 1: 1 else: 0)

proc isSameRowChainedRollMix(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isChainedRollMix(row0, col0, row1, col1, row2, col2, row3, col3) == 1 and
             isSameRowModBi(row0, col0, row1, col1) == 1 and
             isSameRowModBi(row2, col2, row3, col3) == 1: 1 else: 0)

proc isAdjacentFingerChainedRoll(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isChainedRoll(row0, col0, row1, col1, row2, col2, row3, col3) == 1 and
             isAdjacentFingerBi(row0, col0, row1, col1) == 1 and
             isAdjacentFingerBi(row2, col2, row3, col3) == 1: 1 else: 0)

proc isAdjacentFingerChainedRollIn(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isChainedRollIn(row0, col0, row1, col1, row2, col2, row3, col3) == 1 and
             isAdjacentFingerBi(row0, col0, row1, col1) == 1 and
             isAdjacentFingerBi(row2, col2, row3, col3) == 1: 1 else: 0)

proc isAdjacentFingerChainedRollOut(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isChainedRollOut(row0, col0, row1, col1, row2, col2, row3, col3) == 1 and
             isAdjacentFingerBi(row0, col0, row1, col1) == 1 and
             isAdjacentFingerBi(row2, col2, row3, col3) == 1: 1 else: 0)

proc isAdjacentFingerChainedRollMix(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isChainedRollMix(row0, col0, row1, col1, row2, col2, row3, col3) == 1 and
             isAdjacentFingerBi(row0, col0, row1, col1) == 1 and
             isAdjacentFingerBi(row2, col2, row3, col3) == 1: 1 else: 0)

proc isSameRowAdjacentFingerChainedRoll(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isChainedRoll(row0, col0, row1, col1, row2, col2, row3, col3) == 1 and
             isSameRowModBi(row0, col0, row1, col1) == 1 and
             isSameRowModBi(row2, col2, row3, col3) == 1 and
             isAdjacentFingerBi(row0, col0, row1, col1) == 1 and
             isAdjacentFingerBi(row2, col2, row3, col3) == 1: 1 else: 0)

proc isSameRowAdjacentFingerChainedRollIn(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isChainedRollIn(row0, col0, row1, col1, row2, col2, row3, col3) == 1 and
             isSameRowModBi(row0, col0, row1, col1) == 1 and
             isSameRowModBi(row2, col2, row3, col3) == 1 and
             isAdjacentFingerBi(row0, col0, row1, col1) == 1 and
             isAdjacentFingerBi(row2, col2, row3, col3) == 1: 1 else: 0)

proc isSameRowAdjacentFingerChainedRollOut(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isChainedRollOut(row0, col0, row1, col1, row2, col2, row3, col3) == 1 and
             isSameRowModBi(row0, col0, row1, col1) == 1 and
             isSameRowModBi(row2, col2, row3, col3) == 1 and
             isAdjacentFingerBi(row0, col0, row1, col1) == 1 and
             isAdjacentFingerBi(row2, col2, row3, col3) == 1: 1 else: 0)

proc isSameRowAdjacentFingerChainedRollMix(row0, col0, row1, col1, row2, col2, row3, col3: int): int =
  return (if isChainedRollMix(row0, col0, row1, col1, row2, col2, row3, col3) == 1 and
             isSameRowModBi(row0, col0, row1, col1) == 1 and
             isSameRowModBi(row2, col2, row3, col3) == 1 and
             isAdjacentFingerBi(row0, col0, row1, col1) == 1 and
             isAdjacentFingerBi(row2, col2, row3, col3) == 1: 1 else: 0)

proc findStatScore(statName: string, statType: char, lt: Layout): float =
  ## Finds the score of a specific statistic in a given layout.
  ## 
  ## Parameters:
  ##   statName: The name of the statistic to find
  ##   statType: The type of the statistic ('m' for monogram, 'b' for bigram, etc.)
  ##   lt: The layout to analyze
  ##
  ## Returns:
  ##   The score of the found statistic. Returns NaN if the statistic is not found.
  
  case statType
  of 'm':
    if statName in lt.monoScore:
      return lt.monoScore[statName]
  of 'b':
    if statName in lt.biScore:
      return lt.biScore[statName]
  of 't':
    if statName in lt.triScore:
      return lt.triScore[statName]
  of 'q':
    if statName in lt.quadScore:
      return lt.quadScore[statName]
  of '1'..'9':
    if statName in lt.skipScore:
      let skipIndex = ord(statType) - ord('1')
      return lt.skipScore[statName][skipIndex]
  else:
    raise newException(ValueError, "Invalid type specified in findStatScore")
  
  return NaN  # Stat not found