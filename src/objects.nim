# Dimensions of the layout grid.
const
  Row = 3'u8
  Col = 12'u8
  Dim1 = (Row * Col).int
  Dim2 = Dim1 * Dim1
  Dim3 = Dim2 * Dim1
  Dim4 = Dim3 * Dim1

type
  # Structure for a keyboard layout and its stats.
  Layout = object
    name: string
    matrix: array[Row.int, array[Col.int, int]]
    monoScore: Table[string, float]
    biScore: Table[string, float]
    triScore: Table[string, float]
    quadScore: Table[string, float]
    skipScore: Table[string, array[SkipLength, float]]
    metaScore: Option[float]
    score: float

  # 24 bits available
  # Layout:
  # Byte 0: [row0:2|col0:4|row1:2]
  # Byte 1: [col1:4|row2:2|col2:4]
  # Byte 2: [row3:2|col3:4|unused:2]
  PackedQuad = array[3, uint8]

  # 24 bits available
  # Layout:
  # Byte 0: [row0:2|col0:4|row1:2]
  # Byte 1: [col1:4|row2:2|col2_hi:2]
  # Byte 2: [col2_lo:2|unused:6]
  PackedTri = array[3, uint8]

  # 16 bits available
  # Layout:
  # Byte 0: [row0:2|col0:4|row1:2]
  # Byte 1: [col1:4|unused:4]
  PackedBi = array[2, uint8]

  # Structures to represent statistics based on ngrams.
  MonoStat = object
    ngrams: seq[uint8]
    weight: float

  BiStat = object
    ngrams: seq[PackedBi]
    weight: float

  TriStat = object
    ngrams: seq[PackedTri]
    weight: float

  QuadStat = object
    ngrams: seq[PackedQuad]
    weight: float

  SkipStat = object
    ngrams: seq[PackedBi]
    weight: seq[float]  # Multiple weights for skip-X-grams

  # Structure to represent a meta statistic.
  MetaStat = object
    weight: float

# Use tables to store stats by name
var
  monoStats = initTable[string, MonoStat]()
  biStats = initTable[string, BiStat]()
  triStats = initTable[string, TriStat]()
  quadStats = initTable[string, QuadStat]()
  skipStats = initTable[string, SkipStat]()
  metaStats = initTable[string, MetaStat]()

# Use sequences to store layouts
var layoutList: seq[Layout] = @[]
