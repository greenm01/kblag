proc logLayoutsPerSecond(layoutsAnalyzed: float64, elapsedMs: float64) =
  let elapsedSeconds = elapsedMs / 1000.0
  echo "\nLayouts per second........................: ", formatFloat(layoutsAnalyzed / elapsedSeconds, ffDecimal, 6)

proc packBi(row0, col0, row1, col1: int): PackedBi {.inline.} =
 assert row0 in 0..2 and row1 in 0..2
 assert col0 in 0..11 and col1 in 0..11

 # Byte 0: [row0:2|col0:4|row1:2]
 result[0] = uint8((row0 shl 6) or (col0 shl 2) or row1)
 # Byte 1: [col1:4|unused:4]
 result[1] = uint8(col1 shl 4)

proc unpackBi(packed: PackedBi, row0, col0, row1, col1: var int) {.inline.} =
 row0 = int(packed[0] shr 6)            # Top 2 bits
 col0 = int((packed[0] shr 2) and 0xF)  # Next 4 bits
 row1 = int(packed[0] and 0x3)          # Bottom 2 bits
 col1 = int(packed[1] shr 4)            # Top 4 bits of byte 1

proc packTri(row0, col0, row1, col1, row2, col2: int): PackedTri {.inline.} =
 assert row0 in 0..2 and row1 in 0..2 and row2 in 0..2
 assert col0 in 0..11 and col1 in 0..11 and col2 in 0..11

 # Byte 0: [row0:2|col0:4|row1:2]
 result[0] = uint8((row0 shl 6) or (col0 shl 2) or row1)
 # Byte 1: [col1:4|row2:2|col2_hi:2]
 result[1] = uint8((col1 shl 4) or (row2 shl 2) or (col2 shr 2))
 # Byte 2: [col2_lo:2|unused:6]
 result[2] = uint8((col2 and 0x3) shl 6)

proc unpackTri(packed: PackedTri, row0, col0, row1, col1, row2, col2: var int) {.inline.} =
 row0 = int(packed[0] shr 6)            # Top 2 bits
 col0 = int((packed[0] shr 2) and 0xF)  # Next 4 bits
 row1 = int(packed[0] and 0x3)          # Bottom 2 bits

 col1 = int(packed[1] shr 4)            # Top 4 bits
 row2 = int((packed[1] shr 2) and 0x3)  # Next 2 bits
 let col2_hi = int(packed[1] and 0x3)   # Bottom 2 bits

 let col2_lo = int(packed[2] shr 6)     # Top 2 bits
 col2 = (col2_hi shl 2) or col2_lo      # Combine for full col2

proc packQuad(row0, col0, row1, col1, row2, col2, row3, col3: int): PackedQuad {.inline.} =
  assert row0 in 0..2 and row1 in 0..2 and row2 in 0..2 and row3 in 0..2
  assert col0 in 0..11 and col1 in 0..11 and col2 in 0..11 and col3 in 0..11

  # Byte 0: [row0:2|col0:4|row1:2]
  result[0] = uint8((row0 shl 6) or (col0 shl 2) or row1)

  # Byte 1: [col1:4|row2:2|col2_hi:2]
  result[1] = uint8((col1 shl 4) or (row2 shl 2) or (col2 shr 2))

  # Byte 2: [col2_lo:2|row3:2|col3:4]
  let col2_bits = uint8(col2 and 0x3)
  let row3_bits = uint8(row3)
  let col3_bits = uint8(col3)
  result[2] = uint8((col2_bits shl 6) or (row3_bits shl 4) or col3_bits)

proc unpackQuad(packed: PackedQuad, row0, col0, row1, col1, row2, col2, row3, col3: var int) {.inline.} =
  # Byte 0
  row0 = int(packed[0] shr 6)            # Top 2 bits
  col0 = int((packed[0] shr 2) and 0xF)  # Next 4 bits
  row1 = int(packed[0] and 0x3)          # Bottom 2 bits

  # Byte 1
  col1 = int(packed[1] shr 4)            # Top 4 bits
  row2 = int((packed[1] shr 2) and 0x3)  # Next 2 bits
  let col2_hi = int(packed[1] and 0x3)   # Bottom 2 bits

  # Byte 2
  let col2_lo = int(packed[2] shr 6)     # Top 2 bits
  col2 = (col2_hi shl 2) or col2_lo      # Combine for full col2
  row3 = int((packed[2] shr 4) and 0x3)  # Next 2 bits
  col3 = int(packed[2] and 0xF)          # Bottom 4 bits

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

#  * Unflattens a 1D index into a 2D matrix coordinate.
#  * Parameters:
#  *     i: The flattened index.
#  *     row0, col0: Pointers to store the row and column indices.
#  * Returns: void.
proc unflatMono(i: int, row0, col0: var int)  {.inline.} =
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
  i * langLength + j

proc indexTri(i, j, k: int): int =
  ## Computes the index for a trigram in a linearized array.
  ##
  ## Parameters:
  ##   i, j, k: The indices of the characters in the language array.
  ## Returns: The index in the linearized trigram array.
  i * langLength * langLength + j * langLength + k

proc indexQuad(i, j, k, l: int): int =
  ## Computes the index for a quadgram in a linearized array.
  ##
  ## Parameters:
  ##   i, j, k, l: The indices of the characters in the language array.
  ## Returns: The index in the linearized quadgram array.
  i * langLength * langLength * langLength + j * langLength * langLength + k * langLength + l

proc indexSkip(skipIndex, j, k: int): int =
  ## Computes the index for a skipgram in a linearized array.
  ##
  ## Parameters:
  ##   skipIndex: The skip distance (1-9).
  ##   j, k: The indices of the characters in the language array.
  ## Returns: The index in the linearized skipgram array.
  skipIndex * langLength  * langLength + j * langLength + k

proc normalizeCorpus() =
  var totalMono: int = 0
  var totalBi: int = 0
  var totalTri: int = 0
  var totalQuad: int = 0
  var totalSkip: array[SkipLength, int] = [0, 0, 0, 0, 0, 0, 0, 0, 0]

  # Calculate totals
  for i in 0..<langLength:
    totalMono += corpusMono[i]
    for j in 0..<langLength:
      totalBi += corpusBi[i][j]
      for k in 0..<langLength:
        totalTri += corpusTri[i][j][k]
        for l in 0..<langLength:
          totalQuad += corpusQuad[i][j][k][l]

  for i in 0..<SkipLength:
    for j in 0..<langLength:
      for k in 0..<langLength:
        totalSkip[i] += corpusSkip[i][j][k]

  # Normalize monograms
  if totalMono > 0:
    for i in 0..<langLength:
      linearMono[indexMono(i)] = corpusMono[i].float * 100.0 / totalMono.float

  # Normalize bigrams
  if totalBi > 0:
    for i in 0..<langLength:
      for j in 0..<langLength:
        linearBi[indexBi(i,j)] = corpusBi[i][j].float * 100.0 / totalBi.float

  # Normalize trigrams
  if totalTri > 0:
    for i in 0..<langLength:
      for j in 0..<langLength:
        for k in 0..<langLength:
          linearTri[indexTri(i,j,k)] =
            corpusTri[i][j][k].float * 100.0 / totalTri.float

  # Normalize quadgrams
  if totalQuad > 0:
    for i in 0..<langLength:
      for j in 0..<langLength:
        for k in 0..<langLength:
          for l in 0..<langLength:
            linearQuad[indexQuad(i,j,k,l)] =
              corpusQuad[i][j][k][l].float * 100.0 / totalQuad.float

  # Normalize skipgrams
  for i in 0..<SkipLength:
    if totalSkip[i] > 0:
      for j in 0..<langLength:
        for k in 0..<langLength:
          linearSkip[indexSkip(i,j,k)] =
            corpusSkip[i][j][k].float * 100.0 / totalSkip[i].float

proc testBigramEquivalence() =
  var
    flat_row0, flat_col0, flat_row1, flat_col1: int
    pack_row0, pack_col0, pack_row1, pack_col1: int
    flat_i: int
    mismatches = 0
    total = 0

  # Test all valid positions
  for row0 in 0..<Row:
    for col0 in 0..<Col:
      for row1 in 0..<Row:
        for col1 in 0..<Col:
          inc total

          # Original flattened method
          flatBi(row0, col0, row1, col1, flat_i)
          unflatBi(flat_i, flat_row0, flat_col0, flat_row1, flat_col1)

          # New bit packed method
          let packed = packBi(row0, col0, row1, col1)
          unpackBi(packed, pack_row0, pack_col0, pack_row1, pack_col1)

          # Compare
          if flat_row0 != pack_row0 or flat_col0 != pack_col0 or
            flat_row1 != pack_row1 or flat_col1 != pack_col1:
            inc mismatches
            echo "Input: (", row0, ",", col0, ",", row1, ",", col1, ")"
            echo "Original flat index: ", flat_i
            echo "Original result: ", flat_row0, ",", flat_col0, ":", flat_row1, ",", flat_col1
            echo "Bit packed result: ", pack_row0, ",", pack_col0, ":", pack_row1, ",", pack_col1
            echo "---"

  echo "Tested ", total, " combinations"
  echo "Found ", mismatches, " mismatches"

proc testTrigramEquivalence() =
  var
    flat_row0, flat_col0, flat_row1, flat_col1, flat_row2, flat_col2: int
    pack_row0, pack_col0, pack_row1, pack_col1, pack_row2, pack_col2: int
    flat_i: int
    mismatches = 0
    total = 0

  # Test all valid combinations
  for row0 in 0..<Row:
    for col0 in 0..<Col:
      for row1 in 0..<Row:
        for col1 in 0..<Col:
          for row2 in 0..<Row:
            for col2 in 0..<Col:
              inc total

              # Original flattened method
              flatTri(row0, col0, row1, col1, row2, col2, flat_i)
              unflatTri(flat_i, flat_row0, flat_col0, flat_row1, flat_col1, flat_row2, flat_col2)

              # New bit packed method
              let packed = packTri(row0, col0, row1, col1, row2, col2)
              unpackTri(packed, pack_row0, pack_col0, pack_row1, pack_col1, pack_row2, pack_col2)

              # Compare
              if flat_row0 != pack_row0 or flat_col0 != pack_col0 or
                flat_row1 != pack_row1 or flat_col1 != pack_col1 or
                flat_row2 != pack_row2 or flat_col2 != pack_col2:
                inc mismatches
                echo "Input: (", row0, ",", col0, ",", row1, ",", col1, ",", row2, ",", col2, ")"
                echo "Original flat index: ", flat_i
                echo "Original result: ", flat_row0, ",", flat_col0, ":", flat_row1, ",", flat_col1, ":", flat_row2, ",", flat_col2
                echo "Bit packed result: ", pack_row0, ",", pack_col0, ":", pack_row1, ",", pack_col1, ":", pack_row2, ",", pack_col2
                echo "---"

  echo "Tested ", total, " combinations"
  echo "Found ", mismatches, " mismatches"

proc testQuadgramEquivalence() =
  var
    flat_row0, flat_col0, flat_row1, flat_col1: int
    flat_row2, flat_col2, flat_row3, flat_col3: int
    pack_row0, pack_col0, pack_row1, pack_col1: int
    pack_row2, pack_col2, pack_row3, pack_col3: int
    flat_i: int
    mismatches = 0
    total = 0

  # Test subset of positions for demonstration
  for row0 in 0..<Row:
    for col0 in 0..<Col:
      for row1 in 0..<Row:
        for col1 in 0..<Col:
          for row2 in 0..<Row:
            for col2 in 0..<Col:
              for row3 in 0..<Row:
                for col3 in 0..<Col:
                  inc total

                  # Original flattened method
                  flatQuad(row0, col0, row1, col1, row2, col2, row3, col3, flat_i)
                  unflatQuad(flat_i, flat_row0, flat_col0, flat_row1, flat_col1,
                            flat_row2, flat_col2, flat_row3, flat_col3)

                  # New bit packed method
                  let packed = packQuad(row0, col0, row1, col1, row2, col2, row3, col3)
                  unpackQuad(packed, pack_row0, pack_col0, pack_row1, pack_col1,
                            pack_row2, pack_col2, pack_row3, pack_col3)

                  # Compare results
                  if flat_row0 != pack_row0 or flat_col0 != pack_col0 or
                      flat_row1 != pack_row1 or flat_col1 != pack_col1 or
                      flat_row2 != pack_row2 or flat_col2 != pack_col2 or
                      flat_row3 != pack_row3 or flat_col3 != pack_col3:
                    inc mismatches
                    echo "Input: (", row0, ",", col0, ",", row1, ",", col1, ",",
                                      row2, ",", col2, ",", row3, ",", col3, ")"
                    echo "Original flat index: ", flat_i
                    echo "Original result: ", flat_row0, ",", flat_col0, ":",
                                              flat_row1, ",", flat_col1, ":",
                                              flat_row2, ",", flat_col2, ":",
                                              flat_row3, ",", flat_col3
                    echo "Bit packed result: ", pack_row0, ",", pack_col0, ":",
                                              pack_row1, ",", pack_col1, ":",
                                              pack_row2, ",", pack_col2, ":",
                                              pack_row3, ",", pack_col3
                    # Show hex values instead of binary
                    echo "Packed bytes: [0x", toHex(packed[0]), "] [0x",
                                                toHex(packed[1]), "] [0x",
                                                toHex(packed[2]), "]"
                    echo "---"

  echo "Tested ", total, " combinations"
  echo "Found ", mismatches, " mismatches"
