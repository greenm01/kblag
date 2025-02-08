type
  MonoCondition = proc(map: FingerMap, row0, col0: int): bool {.closure.}

proc processMono(map: FingerMap, stat: string, condition: MonoCondition) =
  var monoStat = MonoStat(
    ngrams: newSeq[int](),
    weight: -Inf
  )
  for i in 0..<Dim1:
    var row0, col0: int
    unflatMono(i, row0, col0)
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

  # Initialize finger-specific stats
  for finger in Finger:
    processMono(map, fingerStatNames[finger],
      proc(map: FingerMap, row0, col0: int): bool =
        let f = getFinger(map, row0, col0)
        f.isSome and f.get == finger
    )

  # Initialize stretch and inner position stats
  # Left outer (stretches)
  processMono(map, "Left Outer Usage",
    proc(map: FingerMap, row0, col0: int): bool =
      let f = getFinger(map, row0, col0)
      isStretch(map, row0, col0) and
      (if f.isSome: getHand(f) == some(Left) else: false)
  )

  # Left inner (index finger positions)
  processMono(map, "Left Inner Usage",
    proc(map: FingerMap, row0, col0: int): bool =
      let f = getFinger(map, row0, col0)
      f.isSome and f.get == LI and not isStretch(map, row0, col0)
  )

  # Right inner (index finger positions)
  processMono(map, "Right Inner Usage",
    proc(map: FingerMap, row0, col0: int): bool =
      let f = getFinger(map, row0, col0)
      f.isSome and f.get == RI and not isStretch(map, row0, col0)
  )

  # Right outer (stretches)
  processMono(map, "Right Outer Usage",
    proc(map: FingerMap, row0, col0: int): bool =
      let f = getFinger(map, row0, col0)
      isStretch(map, row0, col0) and
      (if f.isSome: getHand(f) == some(Right) else: false)
  )

  # Initialize row-specific stats
  for row in 0..2:
    processMono(map, rowStatNames[row],
      proc(map: FingerMap, row0, col0: int): bool =
        row0 == row
    )

  # Initialize hand-specific stats
  for hand in Hand:
    processMono(map, handStatNames[hand],
      proc(map: FingerMap, row0, col0: int): bool =
        let f = getFinger(map, row0, col0)
        if f.isNone:
          return false
        getHand(f) == some(hand)
    )
