type
  PinkyMetrics = object
    topRowCount: int
    bottomRowCount: int 
    topRowPercent: float
    bottomRowPercent: float
    stretches: int
    sameFingerBigrams: int
    consecUpperReaches: int
    consecLowerReaches: int
    totalPinkyUse: int

proc analyzePinkyStrain*(text: string, layout: Layout): PinkyMetrics =
  ## Analyzes pinky usage patterns focusing on off-home row movements
  ## Returns detailed metrics about potentially problematic pinky patterns
  
  var metrics = PinkyMetrics()
  var lastWasPinky = false
  var lastPinkyRow = 1  # 1 = home row
  
  # Helper to check if position uses pinky
  proc isPinkyPos(row, col: int): bool =
    col in [0, 1, 10, 11] # Assuming standard pinky columns
  
  # Process each character
  for i, c in text:
    let pos = layout.getKeyPos(c)
    if pos.isNone: continue
    
    let (row, col) = pos.get()
    
    if isPinkyPos(row, col):
      metrics.totalPinkyUse += 1
      
      # Track off home row usage
      case row
      of 0: # Top row
        metrics.topRowCount += 1
        if lastWasPinky and lastPinkyRow == 0:
          metrics.consecUpperReaches += 1
      of 2: # Bottom row  
        metrics.bottomRowCount += 1
        if lastWasPinky and lastPinkyRow == 2:
          metrics.consecLowerReaches += 1
      else: discard
      
      # Check for stretches
      if col in [0, 11]: # Outer pinky positions
        metrics.stretches += 1
      
      # Check for same finger bigrams
      if lastWasPinky and row != lastPinkyRow:
        metrics.sameFingerBigrams += 1
        
      lastWasPinky = true
      lastPinkyRow = row
    else:
      lastWasPinky = false
  
  # Calculate percentages
  if metrics.totalPinkyUse > 0:
    metrics.topRowPercent = metrics.topRowCount.float / metrics.totalPinkyUse.float
    metrics.bottomRowPercent = metrics.bottomRowCount.float / metrics.totalPinkyUse.float
  
  metrics

proc formatPinkyAnalysis*(metrics: PinkyMetrics): string =
  ## Creates a human-readable report of pinky usage metrics
  
  result = """Pinky Usage Analysis:
  Total Pinky Usage: $1 keystrokes
  
  Off Home Row:
    Top Row: $2 ($3%.1f)
    Bottom Row: $4 ($5%.1f)
  
  Strain Patterns:
    Stretches: $6
    Same Finger Bigrams: $7
    Consecutive Upper Reaches: $8
    Consecutive Lower Reaches: $9
    
  Risk Assessment:
    $10
  """.fmt(
    metrics.totalPinkyUse,
    metrics.topRowCount,
    metrics.topRowPercent * 100,
    metrics.bottomRowCount,
    metrics.bottomRowPercent * 100,
    metrics.stretches,
    metrics.sameFingerBigrams,
    metrics.consecUpperReaches,
    metrics.consecLowerReaches,
    assessPinkyRisk(metrics)
  )

proc assessPinkyRisk*(metrics: PinkyMetrics): string =
  ## Provides a risk assessment based on pinky usage patterns
  
  var riskFactors: seq[string]
  
  if metrics.topRowPercent > 0.15:
    riskFactors.add("High upper row pinky usage")
  
  if metrics.bottomRowPercent > 0.12:
    riskFactors.add("High bottom row pinky usage")
    
  if metrics.consecUpperReaches > metrics.totalPinkyUse.float * 0.1:
    riskFactors.add("Frequent consecutive upper reaches")
    
  if metrics.consecLowerReaches > metrics.totalPinkyUse.float * 0.08:
    riskFactors.add("Frequent consecutive lower reaches")
    
  if metrics.sameFingerBigrams > metrics.totalPinkyUse.float * 0.05:
    riskFactors.add("High same-finger bigram count")
    
  if metrics.stretches > metrics.totalPinkyUse.float * 0.07:
    riskFactors.add("Excessive pinky stretches")
    
  if riskFactors.len == 0:
    return "Low Risk - Pinky usage appears reasonable"
  elif riskFactors.len <= 2:
    return "Moderate Risk - Consider addressing:\n    • " & riskFactors.join("\n    • ")
  else:
    return "High Risk - Multiple concerning patterns:\n    • " & riskFactors.join("\n    • ")