proc flatQuad(row0, col0, row1, col1, row2, col2, row3, col3: int, i: var int) =
  ## Flattens an 8D matrix coordinate into a 1D index.
  ## 
  ## Parameters:
  ##   row0, col0, row1, col1, row2, col2, row3, col3: The row and column indices of the 8D matrix.
  ##   i: The resulting flattened 1D index (output parameter).
  i = ((row0 * Col + col0) * Dim3) +
      ((row1 * Col + col1) * Dim2) +
      ((row2 * Col + col2) * Dim1) +
      (row3 * Col + col3)

proc unflatQuad(i: int, row0, col0, row1, col1, row2, col2, row3, col3: var int) = 
 # Starting from lowest dimension:
 # Get row3,col3 from lowest Dim1
 row3 = (i mod Dim1) div Col
 col3 = i mod Col

 # Move up to next Dim1 block
 var temp = i div Dim1
 row2 = (temp mod Dim1) div Col 
 col2 = temp mod Col

 # Move up again
 temp = temp div Dim1
 row1 = (temp mod Dim1) div Col
 col1 = temp mod Col

 # Final dimension
 temp = temp div Dim1
 row0 = temp div Col
 col0 = temp mod Col

proc flatTri(row0, col0, row1, col1, row2, col2: int, i: var int) =
  ## Flattens a 6D matrix coordinate into a 1D index.
  ## 
  ## Parameters:
  ##   row0, col0, row1, col1, row2, col2: The row and column indices of the 6D matrix.
  ##   i: The resulting flattened 1D index (output parameter).
  i = ((row0 * Col + col0) * Dim2) +
      ((row1 * Col + col1) * Dim1) +
      (row2 * Col + col2)

proc unflatTri(i: int, row0, col0, row1, col1, row2, col2: var int) =
  ## Unflattens a 1D index into a 6D matrix coordinate.
  ## 
  ## Parameters:
  ##   i: The flattened 1D index.
  ##   row0, col0, row1, col1, row2, col2: The resulting row and column indices (output parameters).
  row2 = (i mod Dim1) div Col
  col2 = i mod Col
  var i = i div Dim1

  row1 = (i mod Dim1) div Col
  col1 = i mod Col
  i = i div Dim1

  row0 = i div Col
  col0 = i mod Col

proc flatBi(row0, col0, row1, col1: int, i: var int) =
  ## Flattens a 4D matrix coordinate into a 1D index.
  ## 
  ## Parameters:
  ##   row0, col0, row1, col1: The row and column indices of the 4D matrix.
  ##   i: The resulting flattened 1D index (output parameter).
  i = ((row0 * Col + col0) * Dim1) +
      (row1 * Col + col1)

proc unflatBi(i: int, row0, col0, row1, col1: var int) =
  ## Unflattens a 1D index into a 4D matrix coordinate.
  ## 
  ## Parameters:
  ##   i: The flattened 1D index.
  ##   row0, col0, row1, col1: The resulting row and column indices (output parameters).
  row1 = (i mod Dim1) div Col
  col1 = i mod Col
  var i = i div Dim1

  row0 = i div Col
  col0 = i mod Col

proc flatMono(row0, col0: int, i: var int) =
  ## Flattens a 2D matrix coordinate into a 1D index.
  ## 
  ## Parameters:
  ##   row0, col0: The row and column indices of the 2D matrix.
  ##   i: The resulting flattened 1D index (output parameter).
  i = row0 * Col + col0

proc unflatMono(i: int, row0, col0: var int) =
  ## Unflattens a 1D index into a 2D matrix coordinate.
  ## 
  ## Parameters:
  ##   i: The flattened 1D index.
  ##   row0, col0: The resulting row and column indices (output parameters).    
  row0 = i div Col
  col0 = i mod Col

proc indexMono(i: int): int =
  ## Computes the index for a monogram in a linearized array.
  ## 
  ## Parameters:
  ##   i: The index of the character in the language array.
  ## Returns: The index in the linearized monogram array.
  i

proc indexBi(i, j: int): int =
  ## Computes the index for a bigram in a linearized array.
  ## 
  ## Parameters:
  ##   i, j: The indices of the characters in the language array.
  ## Returns: The index in the linearized bigram array.
  i * LangLength + j

proc indexTri(i, j, k: int): int =
  ## Computes the index for a trigram in a linearized array.
  ## 
  ## Parameters:
  ##   i, j, k: The indices of the characters in the language array.
  ## Returns: The index in the linearized trigram array.
  i * LangLength * LangLength + j * LangLength + k

proc indexQuad(i, j, k, l: int): int =
  ## Computes the index for a quadgram in a linearized array.
  ## 
  ## Parameters:
  ##   i, j, k, l: The indices of the characters in the language array.
  ## Returns: The index in the linearized quadgram array.
  i * LangLength * LangLength * LangLength + j * LangLength * LangLength + k * LangLength + l

proc indexSkip(skipIndex, j, k: int): int =
  ## Computes the index for a skipgram in a linearized array.
  ## 
  ## Parameters:
  ##   skipIndex: The skip distance (1-9).
  ##   j, k: The indices of the characters in the language array.
  ## Returns: The index in the linearized skipgram array.
  skipIndex * LangLength  * LangLength + j * LangLength + k

proc normalizeCorpus() =
  var totalMono: int = 0
  var totalBi: int = 0
  var totalTri: int = 0 
  var totalQuad: int = 0
  var totalSkip: array[SkipLength, int] = [0, 0, 0, 0, 0, 0, 0, 0, 0]

  # Calculate totals
  for i in 0..<LangLength:
    totalMono += corpusMono[i]
    for j in 0..<LangLength:
      totalBi += corpusBi[i][j]
      for k in 0..<LangLength:
        totalTri += corpusTri[i][j][k]
        for l in 0..<LangLength:
          totalQuad += corpusQuad[i][j][k][l]

  for i in 0..<SkipLength:
    for j in 0..<LangLength:
      for k in 0..<LangLength:
        totalSkip[i] += corpusSkip[i][j][k]

  # Normalize monograms
  if totalMono > 0:
    for i in 0..<LangLength:
      linearMono[indexMono(i)] = corpusMono[i].float * 100.0 / totalMono.float

  # Normalize bigrams
  if totalBi > 0:
    for i in 0..<LangLength:
      for j in 0..<LangLength:
        linearBi[indexBi(i,j)] = corpusBi[i][j].float * 100.0 / totalBi.float

  # Normalize trigrams
  if totalTri > 0:
    for i in 0..<LangLength:
      for j in 0..<LangLength:
        for k in 0..<LangLength:
          linearTri[indexTri(i,j,k)] = 
            corpusTri[i][j][k].float * 100.0 / totalTri.float

  # Normalize quadgrams
  if totalQuad > 0:
    for i in 0..<LangLength:
      for j in 0..<LangLength:
        for k in 0..<LangLength:
          for l in 0..<LangLength:
            linearQuad[indexQuad(i,j,k,l)] = 
              corpusQuad[i][j][k][l].float * 100.0 / totalQuad.float

  # Normalize skipgrams
  for i in 0..<SkipLength:
    if totalSkip[i] > 0:
      for j in 0..<LangLength:
        for k in 0..<LangLength:
          linearSkip[indexSkip(i,j,k)] = 
            corpusSkip[i][j][k].float * 100.0 / totalSkip[i].float