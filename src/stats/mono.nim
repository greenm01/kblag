type
  MonoCondition = proc(map: FingerMap, row0, col0: uint8): bool {.closure.}

proc processMono(map: FingerMap, stat: string, condition: MonoCondition) =
  var monoStat = MonoStat(
    ngrams: newSeq[uint8](),
    weight: -Inf
  )
  for i in countup(uint8(Dim1)):
    var row0 = i div Col
    var col0 = i mod Col
    if condition(map, row0, col0):
      monoStat.ngrams.add(i)

  monoStats[stat] = monoStat

proc initializeMonoStats(map: FingerMap) =
  const
    fingerStatNames = {
      LP: "Left Pinky Usage",
      LR: "Left Ring Usage",
      LM: "Left Middle Usage",
      LI: "Left Index Usage",
      RI: "Right Index Usage",
      RM: "Right Middle Usage",
      RR: "Right Ring Usage",
      RP: "Right Pinky Usage"
    }.toTable

    rowStatNames = {
      0: "Top Row Usage",
      1: "Home Row Usage",
      2: "Bottom Row Usage"
    }.toTable

    handStatNames = {
      Left: "Left Hand Usage",
      Right: "Right Hand Usage"
    }.toTable

  # Helper to check if position is valid (not @)
  proc isValidPosition(map: FingerMap, row, col: uint8): bool =
    let f = getFinger(map, row, col)
    f.isSome  # Position has a finger assigned

  # Left outer (stretches)
  processMono(map, "Left Outer Usage",
    proc(map: FingerMap, row0, col0: uint8): bool =
      col0 == 0'u8
  )

  # Right outer (stretches)
  processMono(map, "Right Outer Usage",
    proc(map: FingerMap, row0, col0: uint8): bool =
      col0 == 11'u8
  )

  # Inner positions
  processMono(map, "Left Inner Usage",
    proc(map: FingerMap, row0, col0: uint8): bool =
      col0 == 5'u8
  )

  processMono(map, "Right Inner Usage",
    proc(map: FingerMap, row0, col0: uint8): bool =
      col0 == 6'u8
  )

  # For finger-specific stats
  for finger in Finger:
    processMono(map, fingerStatNames[finger],
      proc(map: FingerMap, row0, col0: uint8): bool =
        let f = getFinger(map, row0, col0)
        if not isValidPosition(map, row0, col0):
          return false
        f.get == finger
    )

  # For hand stats
  for hand in Hand:
    processMono(map, handStatNames[hand],
      proc(map: FingerMap, row0, col0: uint8): bool =
        let f = getFinger(map, row0, col0)
        if not isValidPosition(map, row0, col0):
          return false
        getHand(f).get == hand
    )

  # For row stats
  for row in 0..2:
    processMono(map, rowStatNames[row],
      proc(map: FingerMap, row0, col0: uint8): bool =
        if not isValidPosition(map, row0, col0):
          return false
        row0 == uint8(row)
    )
