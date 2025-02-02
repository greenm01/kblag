type
  MonoCondition = proc(row0, col0: int): bool {.closure.}

proc processMono(stat: string, condition: MonoCondition) =
  var monoStat = MonoStat(
    ngrams: newSeq[int](),
    weight: -Inf
  )
  for i in 0..<Dim1:
    var row0, col0: int
    unflatMono(i, row0, col0)
    if condition(row0, col0): 
      monoStat.ngrams.add(i)

  monoStats[stat] = monoStat

proc initializeMonoStats() =
  const 
    fingerStatNames: array[8, string] = [
      "Left Pinky Usage",
      "Left Ring Usage",
      "Left Middle Usage",
      "Left Index Usage",
      "Right Index Usage",
      "Right Middle Usage",
      "Right Ring Usage",
      "Right Pinky Usage"
    ]

    columnStatNames: array[12, string] = [
      "Left Outer Usage",    # Column 0
      "", "", "", "",        # Columns 1-4 (unused)
      "Left Inner Usage",    # Column 5
      "Right Inner Usage",   # Column 6
      "", "", "", "",        # Columns 7-10 (unused)
      "Right Outer Usage"    # Column 11
    ]

    rowStatNames: array[3, string] = [
      "Top Row Usage",       # Row 0
      "Home Row Usage",      # Row 1
      "Bottom Row Usage"     # Row 2
    ]

    handStatNames: array[Hand, string] = [
      "Left Hand Usage",     # Hand.leftHand
      "Right Hand Usage"     # Hand.rightHand
    ]

  # Initialize finger-specific stats
  for fing in 0..7:
    let fingCopy = fing  # Create a copy for closure
    processMono(fingerStatNames[fing], proc(row0, col0: int): bool =
      finger(row0, col0) == fingCopy
    )

  # Initialize column-specific stats
  for col in [0, 5, 6, 11]:
    let colCopy = col  # Create a copy for closure
    processMono(columnStatNames[col], proc(row0, col0: int): bool =
      col0 == colCopy
    )

  # Initialize row-specific stats
  for row in 0..2:
    let rowCopy = row  # Create a copy for closure
    processMono(rowStatNames[row], proc(row0, col0: int): bool =
      row0 == rowCopy
    )

  # Initialize hand-specific stats
  for h in Hand:
    let hCopy = h  # Create a copy for closure
    processMono(handStatNames[h], proc(row0, col0: int): bool =
      getHand(row0, col0) == hCopy 
    )