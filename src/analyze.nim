proc singleAnalyze(lt: var Layout, map: var FingerMap) =
  # Calculate monogram statistics
  for name, stat in monoStats:
    var score = 0.0
    for ngram in stat.ngrams:
      let key = lt.matrix[(ngram div Col).int][(ngram mod Col).int]
      if key != -1:
        score += linearMono[key]
    lt.monoScore[name] += score

  # Calculate bigram statistics
  for name, stat in biStats:
    var score = 0.0
    for packed in stat.ngrams:
      let byte0 = packed[0]
      let byte1 = packed[1]

      # Direct matrix lookups using unpacked bits
      let key1 = lt.matrix[(byte0 shr 6).int][(byte0 shr 2 and 0xF'u8).int]
      let key2 = lt.matrix[(byte0 and 0x3'u8).int][(byte1 shr 4).int]

      if key1 != -1 and key2 != -1:
        score += linearBi[key1 * mul1 + key2]
    lt.biScore[name] += score

  # Calculate trigram statistics
  for name, stat in triStats:
    var score = 0.0
    for packed in stat.ngrams:
      let byte0 = packed[0]
      let byte1 = packed[1]
      let byte2 = packed[2]

      # Direct matrix lookups
      let key1 = lt.matrix[(byte0 shr 6).int][(byte0 shr 2 and 0xF'u8).int]
      let key2 = lt.matrix[(byte0 and 0x3'u8).int][(byte1 shr 4).int]
      let key3 = lt.matrix[(byte1 shr 2 and 0x3'u8).int][((byte1 and 0x3'u8) shl 2 or (byte2 shr 6)).int]

      if key1 != -1 and key2 != -1 and key3 != -1:
        score += linearTri[key1 * mul2 + key2 * mul1 + key3]
    lt.triScore[name] += score

  # Calculate quadgram statistics
  for name, stat in quadStats:
    var score = 0.0
    for packed in stat.ngrams:
      let byte0 = packed[0]
      let byte1 = packed[1]
      let byte2 = packed[2]

      # Direct matrix lookups
      let key1 = lt.matrix[(byte0 shr 6).int][(byte0 shr 2 and 0xF'u8).int]
      let key2 = lt.matrix[(byte0 and 0x3'u8).int][(byte1 shr 4).int]
      let key3 = lt.matrix[(byte1 shr 2 and 0x3'u8).int][((byte1 and 0x3'u8) shl 2 or (byte2 shr 6)).int]
      let key4 = lt.matrix[(byte2 shr 4 and 0x3'u8).int][(byte2 and 0xF'u8).int]

      if key1 != -1 and key2 != -1 and key3 != -1 and key4 != -1:
        score += linearQuad[key1 * mul3 + key2 * mul2 + key3 * mul1 + key4]
    lt.quadScore[name] += score

  # Calculate skipgram statistics
  for name, stat in skipStats:
    var scores: array[SkipLength, float]
    for packed in stat.ngrams:
      # Direct bit manipulation for unpacking
      let byte0 = packed[0]
      let byte1 = packed[1]

      # Direct matrix lookups
      let key1 = lt.matrix[(byte0 shr 6).int][(byte0 shr 2 and 0xF'u8).int]
      let key2 = lt.matrix[(byte0 and 0x3'u8).int][(byte1 shr 4).int]

      if key1 != -1 and key2 != -1:
        for k in 0..<SkipLength:
          scores[k] += linearSkip[k * mul2 + key1 * mul1 + key2]

    # Update all skip scores at once
    for k in 0..<SkipLength:
      lt.skipScore[name][k] += scores[k]

  # Perform meta-analysis
  metaAnalysis(lt, map)

proc calcLayoutScore(lt: var Layout) =
  lt.score = 0.0

  for name, stat in monoStats:
    lt.score += lt.monoScore[name] * stat.weight

  for name, stat in biStats:
    lt.score += lt.biScore[name] * stat.weight

  for name, stat in triStats:
    lt.score += lt.triScore[name] * stat.weight

  for name, stat in quadStats:
    lt.score += lt.quadScore[name] * stat.weight

  for name, stat in skipStats:
    for k in 0..<SkipLength:
      lt.score += lt.skipScore[name][k] * stat.weight[k]

  for name, metaStat in metaStats:
    if lt.metaScore.isSome:  # Check if we have a valid meta score
      lt.score += lt.metaScore.get() * metaStat.weight

proc analyzeLayout(layout: string, map: var FingerMap) =

  info("Reading layout")
  var lt = readLayout(layout)

  info("Calculating layout scores")

  let startTime = cpuTime()
  singleAnalyze(lt, map)
  calcLayoutScore(lt)
  let endTime = cpuTime()

  let elapsedComputeTime = (endTime - startTime) * 1000
  info("Total layout analysis time: ", elapsedComputeTime, " ms")

  printLayout(lt)

  logLayoutsPerSecond(1.0, elapsedComputeTime)
