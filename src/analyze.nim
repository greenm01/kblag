proc singleAnalyze(lt: var Layout) =
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
    for ngram in stat.ngrams:
      unflatBi(ngram, row0, col0, row1, col1)
      if lt.matrix[row0][col0] != -1 and lt.matrix[row1][col1] != -1:
        let index = indexBi(lt.matrix[row0][col0], lt.matrix[row1][col1])
        lt.biScore[name] += linearBi[index]

  # Calculate trigram statistics
  for name, stat in triStats:
    for ngram in stat.ngrams:
      unflatTri(ngram, row0, col0, row1, col1, row2, col2)
      if lt.matrix[row0][col0] != -1 and lt.matrix[row1][col1] != -1 and
         lt.matrix[row2][col2] != -1:
        let index = indexTri(lt.matrix[row0][col0], lt.matrix[row1][col1],
                           lt.matrix[row2][col2])
        lt.triScore[name] += linearTri[index]

  # Calculate quadgram statistics
  for name, stat in quadStats:
    for ngram in stat.ngrams:
      unflatQuad(ngram, row0, col0, row1, col1, row2, col2, row3, col3)
      if lt.matrix[row0][col0] != -1 and lt.matrix[row1][col1] != -1 and
         lt.matrix[row2][col2] != -1 and lt.matrix[row3][col3] != -1:
        let index = indexQuad(lt.matrix[row0][col0], lt.matrix[row1][col1],
                            lt.matrix[row2][col2], lt.matrix[row3][col3])
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
  metaAnalysis(lt)

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

proc analyzeLayout() = 
  let startTime = cpuTime()

  info("Reading layout")
  var layout = readLayout("consort")

  info("Calculating layout scores")
  singleAnalyze(layout)
  calcLayoutScore(layout)

  let endTime = cpuTime()
  # Calculate elapsed time in milliseconds
  let elapsedTimeMs = (endTime - startTime) * 1000
  info("Total layout analysis time: ", elapsedTimeMs, " ms")
  
  printLayout(layout)