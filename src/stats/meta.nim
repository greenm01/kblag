proc initializeMetaStats() =  # Make map parameter mutable
  metaStats["Hand Balance"] = MetaStat(weight: -Inf)

proc findStatScore(statName: string, statType: char, lt: Layout): float =
  ## Finds the score of a specific statistic in a given layout.
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

proc metaAnalysis(lt: var Layout) =  # Make map parameter mutable
  ## Performs the meta-analysis using the FingerMap and current layout.
  ## Calculates hand balance as the absolute difference between
  ## left and right hand usage.
  ##
  ## Parameters:
  ##   map: The finger mapping configuration (mutable)
  ##   lt: The layout to analyze (modified in-place)

  # Get hand usage scores, preferring existing layout scores
  let
    leftHandScore = findStatScore("Left Hand Usage", 'm', lt)
    rightHandScore = findStatScore("Right Hand Usage", 'm', lt)

  if classify(leftHandScore) == fcNaN or classify(rightHandScore) == fcNaN:
    lt.metaScore = none(float)
  else:
    let handBalance = abs(leftHandScore - rightHandScore)
    lt.metaScore = some(handBalance)

  # Update the map's hand balance
  #map.handBalance[Left] = leftHandScore
  #map.handBalance[Right] = rightHandScore
