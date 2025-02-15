proc singleAnalyze(lt: var Layout, map: var FingerMap) =
  var
    row0, col0, row1, col1, row2, col2, row3, col3: int

  # Calculate monogram statistics
  for name, stat in monoStats:
    for ngram in stat.ngrams:
      unflatMono(ngram, row0, col0)
      if lt.matrix[row0][col0] != -1:
        let index = indexMono(lt.matrix[row0][col0])
        lt.monoScore[name] += linearMono[index]

  # Calculate bigram statistics
  for name, stat in biStats:
    for packed in stat.ngrams:
      var row0, col0, row1, col1: int
      unpackBi(packed, row0, col0, row1, col1)

      let key1 = lt.matrix[row0][col0]
      let key2 = lt.matrix[row1][col1]

      if key1 != -1 and key2 != -1:
        let index = indexBi(key1, key2)
        lt.biScore[name] += linearBi[index]

  # Calculate trigram statistics
  for name, stat in triStats:
    for packed in stat.ngrams:
      var row0, col0, row1, col1, row2, col2: int
      unpackTri(packed, row0, col0, row1, col1, row2, col2)
      #echo row0, ",", col0, ":", row1, ",", col1, ":", row2, ",", col2
      let key1 = lt.matrix[row0][col0]
      let key2 = lt.matrix[row1][col1]
      let key3 = lt.matrix[row2][col2]

      if key1 != -1 and key2 != -1 and key3 != -1:
        let index = indexTri(key1, key2, key3)
        lt.triScore[name] += linearTri[index]

  # Calculate quadgram statistics
  for name, stat in quadStats:
    for packed in stat.ngrams:
      var row0, col0, row1, col1, row2, col2, row3, col3: int
      unpackQuad(packed, row0, col0, row1, col1, row2, col2, row3, col3)

      let key1 = lt.matrix[row0][col0]
      let key2 = lt.matrix[row1][col1]
      let key3 = lt.matrix[row2][col2]
      let key4 = lt.matrix[row3][col3]

      if key1 != -1 and key2 != -1 and key3 != -1 and key4 != -1:
        let index = indexQuad(key1, key2, key3, key4)
        lt.quadScore[name] += linearQuad[index]

  # Calculate skipgram statistics
  for name, stat in skipStats:
    for k in 0..<SkipLength:
      for ngram in stat.ngrams:
        unflatBi(ngram, row0, col0, row1, col1)
        if lt.matrix[row0][col0] != -1 and lt.matrix[row1][col1] != -1:
          let index = indexSkip(k, lt.matrix[row0][col0], lt.matrix[row1][col1])
          lt.skipScore[name][k] += linearSkip[index]

  # Perform meta-analysis, which may depend on previously calculated statistics.
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
  let startTime = cpuTime()

  info("Reading layout")
  # TODO: specify on command line
  var lt = readLayout(layout)

  info("Calculating layout scores")
  singleAnalyze(lt, map)
  calcLayoutScore(lt)

  let endTime = cpuTime()
  let elapsedComputeTime = (endTime - startTime) * 1000
  info("Total layout analysis time: ", elapsedComputeTime, " ms")

  printLayout(lt)

  logLayoutsPerSecond(1.0, elapsedComputeTime)
