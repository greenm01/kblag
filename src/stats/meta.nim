proc initializeMetaStats() =
  metaStats["Hand Balance"] = MetaStat(weight: -Inf)

proc metaAnalysis*(lt: var Layout) =
  ## Performs the meta-analysis on a given layout, calculating meta statistics.
  ## Specifically calculates hand balance as the absolute difference between
  ## left and right hand usage.
  ##
  ## Parameters:
  ##   lt: The layout to analyze (modified in-place)

  # Calculate hand balance
  let 
    leftHandScore = findStatScore("Left Hand Usage", 'm', lt)
    rightHandScore = findStatScore("Right Hand Usage", 'm', lt)

  if classify(leftHandScore) == fcNaN or classify(rightHandScore) == fcNaN:
    lt.metaScore = none(float)  # Use Option's none for invalid/missing scores
  else:
    let handBalance = abs(leftHandScore - rightHandScore)
    lt.metaScore = some(handBalance)  # Wrap the result in Option's some