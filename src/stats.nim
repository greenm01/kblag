include stats/[mono, bigram, tri, quad, skip, meta]

proc initializeStats(map: var FingerMap) =
  info("Initializing monogram stats")
  initializeMonoStats(map)

  info("Initializing bigram stats")
  initializeBigramStats(map)

  info("Initializing trigram stats")
  initializeTrigramStats(map)

  info("Initializing quadgram stats")
  initializeQuadgramStats(map)

  info("Initializing skipgram stats")
  initializeSkipgramStats(map)

  info("Initializing meta stats")
  initializeMetaStats()

# Function to remove entries with zero weight
proc removeZeroWeights[T](stats: var Table[string, T]) =
  var keysToDelete: seq[string] = @[] # Collect keys to delete
  for key in stats.keys:
    if stats[key].weight == 0 or stats[key].ngrams.len == 0:
      keysToDelete.add(key)
  # Delete collected keys
  for key in keysToDelete:
    stats.del(key)

# Special handling for SkipStat (since it has a sequence of weights)
proc removeZeroWeightsSkip(stats: var Table[string, SkipStat]) =
  var keysToDelete: seq[string] = @[] # Collect keys to delete
  for key in stats.keys:
    var allZero = true
    for w in stats[key].weight:
      if w != 0:
        allZero = false
        break
    if allZero:
      keysToDelete.add(key)
  # Delete collected keys
  for key in keysToDelete:
    stats.del(key)

proc cleanStats() =
  ## Remove zero-weight entries from each table
  removeZeroWeights(monoStats)
  removeZeroWeights(biStats)
  removeZeroWeights(triStats)
  removeZeroWeights(quadStats)
  removeZeroWeightsSkip(skipStats)
  #removeZeroWeights(metaStats)
