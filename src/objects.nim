# Dimensions of the layout grid.
const
  Row = 3
  Col = 12
  Dim1 = Row * Col
  Dim2 = Dim1 * Dim1
  Dim3 = Dim2 * Dim1
  Dim4 = Dim3 * Dim1

type
  # Structure for a keyboard layout and its stats.
  Layout = object
    name: string
    matrix: array[Row, array[Col, int]]
    monoScore: Table[string, float]  
    biScore: Table[string, float]    
    triScore: Table[string, float]   
    quadScore: Table[string, float]  
    skipScore: Table[string, array[SkipLength, float]] 
    metaScore: Option[float]
    score: float

  # Structures to represent statistics based on ngrams.
  MonoStat = object
    ngrams: seq[int]
    weight: float

  BiStat = object
    ngrams: seq[int]
    weight: float

  TriStat = object
    ngrams: seq[int]
    weight: float

  QuadStat = object
    ngrams: seq[int]
    weight: float

  SkipStat = object
    ngrams: seq[int]
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