proc logLayoutsPerSecond(layoutsAnalyzed: float64, elapsedMs: float64) =
  let elapsedSeconds = elapsedMs / 1000.0
  echo "\nLayouts per second........................: ", formatFloat(layoutsAnalyzed / elapsedSeconds, ffDecimal, 6)

iterator countup(b: uint8): uint8 =
  ## Fast countup for uint8 avoiding integer promotion
  var i: uint8 = 0
  while i < b:
    yield i
    inc i

proc packBi(row0, col0, row1, col1: uint8): PackedBi {.inline.} =
  assert row0 <= Row and row1 <= Row
  assert col0 < Col and col1 < Col
  result[0] = (row0 shl 6) or (col0 shl 2) or row1
  result[1] = col1 shl 4

proc unpackBi(packed: PackedBi, row0, col0, row1, col1: var uint8) {.inline.} =
  let byte0 = packed[0]
  let byte1 = packed[1]
  row0 = byte0 shr 6
  col0 = (byte0 shr 2) and 0xF'u8
  row1 = byte0 and 0x3'u8
  col1 = byte1 shr 4

proc packTri(row0, col0, row1, col1, row2, col2: uint8): PackedTri {.inline.} =
  assert row0 <= Row and row1 <= Row and row2 <= Row
  assert col0 < Col and col1 < Col and col2 < Col
  result[0] = (row0 shl 6) or (col0 shl 2) or row1
  result[1] = (col1 shl 4) or (row2 shl 2) or (col2 shr 2)
  result[2] = (col2 and 0x3'u8) shl 6

proc unpackTri(packed: PackedTri, row0, col0, row1, col1, row2, col2: var uint8) {.inline.} =
  let byte0 = packed[0]
  let byte1 = packed[1]
  let byte2 = packed[2]
  row0 = byte0 shr 6
  col0 = (byte0 shr 2) and 0xF'u8
  row1 = byte0 and 0x3'u8
  col1 = byte1 shr 4
  row2 = (byte1 shr 2) and 0x3'u8
  let col2_hi = byte1 and 0x3'u8
  let col2_lo = byte2 shr 6
  col2 = (col2_hi shl 2) or col2_lo

proc packQuad(row0, col0, row1, col1, row2, col2, row3, col3: uint8): PackedQuad {.inline.} =
  assert row0 <= Row and row1 <= Row and row2 <= Row and row3 <= Row
  assert col0 < Col and col1 < Col and col2 < Col and col3 < Col
  result[0] = (row0 shl 6) or (col0 shl 2) or row1
  result[1] = (col1 shl 4) or (row2 shl 2) or (col2 shr 2)
  result[2] = ((col2 and 0x3'u8) shl 6) or (row3 shl 4) or col3

proc unpackQuad(packed: PackedQuad, row0, col0, row1, col1, row2, col2, row3, col3: var uint8) {.inline.} =
  let byte0 = packed[0]
  let byte1 = packed[1]
  let byte2 = packed[2]
  row0 = byte0 shr 6
  col0 = (byte0 shr 2) and 0xF'u8
  row1 = byte0 and 0x3'u8
  col1 = byte1 shr 4
  row2 = (byte1 shr 2) and 0x3'u8
  let col2_hi = byte1 and 0x3'u8
  let col2_lo = byte2 shr 6
  col2 = (col2_hi shl 2) or col2_lo
  row3 = (byte2 shr 4) and 0x3'u8
  col3 = byte2 and 0xF'u8

# --- Quad (8D) operations ---
proc flatQuad(row0, col0, row1, col1, row2, col2, row3, col3: int, i: var int) {.inline.} =
  let pos0 = row0 * Col.int + col0
  let pos1 = row1 * Col.int + col1
  let pos2 = row2 * Col.int + col2
  let pos3 = row3 * Col.int + col3
  i = pos0 * Dim3 + pos1 * Dim2 + pos2 * Dim1 + pos3

proc unflatQuad(i: int, row0, col0, row1, col1, row2, col2, row3, col3: var int) {.inline.} =
  # Bottom level (row3, col3)
  let i3 = i mod Dim1
  row3 = i3 div Col.int
  col3 = i3 mod Col.int

  # Third level (row2, col2)
  let i2 = (i div Dim1) mod Dim1
  row2 = i2 div Col.int
  col2 = i2 mod Col.int

  # Second level (row1, col1)
  let i1 = (i div Dim2) mod Dim1
  row1 = i1 div Col.int
  col1 = i1 mod Col.int

  # Top level (row0, col0)
  let i0 = i div Dim3
  row0 = i0 div Col.int
  col0 = i0 mod Col.int

# --- Tri (6D) operations ---
proc flatTri(row0, col0, row1, col1, row2, col2: int, i: var int) {.inline.} =
  let pos0 = row0 * Col.int + col0
  let pos1 = row1 * Col.int + col1
  let pos2 = row2 * Col.int + col2
  i = pos0 * Dim2 + pos1 * Dim1 + pos2

proc unflatTri(i: int, row0, col0, row1, col1, row2, col2: var int) {.inline.} =
  # Bottom level (row2, col2)
  let i2 = i mod Dim1
  row2 = i2 div Col.int
  col2 = i2 mod Col.int

  # Middle level (row1, col1)
  let i1 = (i div Dim1) mod Dim1
  row1 = i1 div Col.int
  col1 = i1 mod Col.int

  # Top level (row0, col0)
  let i0 = i div Dim2
  row0 = i0 div Col.int
  col0 = i0 mod Col.int

# --- Bi (4D) operations ---
proc flatBi(row0, col0, row1, col1: int, i: var int) {.inline.} =
  let pos0 = row0 * Col.int + col0
  let pos1 = row1 * Col.int + col1
  i = pos0 * Dim1 + pos1

proc unflatBi(i: int, row0, col0, row1, col1: var int) {.inline.} =
  # Bottom level (row1, col1)
  let i1 = i mod Dim1
  row1 = i1 div Col.int
  col1 = i1 mod Col.int

  # Top level (row0, col0)
  let i0 = i div Dim1
  row0 = i0 div Col.int
  col0 = i0 mod Col.int

# --- Mono (2D) operations ---
proc unflatMono(i: int, row0, col0: var int) {.inline.} =
  row0 = i div Col.int
  col0 = i mod Col.int

# precomputed langlengths (defined in readLang() from io.nim)
var mul1: int
var mul2: int
var mul3: int

proc indexMono(i: int): int {.inline.} =
  i

proc indexBi(i, j: int): int {.inline.} =
  ## Computes the index for a bigram in a linearized array.
  ##
  ## Parameters:
  ##   i, j: The indices of the characters in the language array.
  ## Returns: The index in the linearized bigram array.
  i * mul1 + j

proc indexTri(i, j, k: int): int {.inline.} =
  ## Computes the index for a trigram in a linearized array.
  ##
  ## Parameters:
  ##   i, j, k: The indices of the characters in the language array.
  ## Returns: The index in the linearized trigram array.
  i * mul2 + j * mul1 + k

proc indexQuad(i, j, k, l: int): int {.inline.} =
  ## Computes the index for a quadgram in a linearized array.
  ##
  ## Parameters:
  ##   i, j, k, l: The indices of the characters in the language array.
  ## Returns: The index in the linearized quadgram array.
  i * mul3 + j * mul2 + k * mul1 + l

proc indexSkip(skipIndex, j, k: int): int {.inline.} =
  ## Computes the index for a skipgram in a linearized array.
  ##
  ## Parameters:
  ##   skipIndex: The skip distance (1-9).
  ##   j, k: The indices of the characters in the language array.
  ## Returns: The index in the linearized skipgram array.
  skipIndex * mul2 + j * mul1 + k

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
    pack_row0, pack_col0, pack_row1, pack_col1: uint8
    flat_i: int
    mismatches = 0
    total = 0

  # Test all valid positions
  for row0 in countup(Row):
    for col0 in countup(Col):
      for row1 in countup(Row):
        for col1 in countup(Col):
          inc total

          # Original flattened method
          flatBi(row0.int, col0.int, row1.int, col1.int, flat_i)
          unflatBi(flat_i, flat_row0, flat_col0, flat_row1, flat_col1)

          # New bit packed method
          let packed = packBi(row0, col0, row1, col1)
          unpackBi(packed, pack_row0, pack_col0, pack_row1, pack_col1)

          # Compare
          if flat_row0 != pack_row0.int or flat_col0 != pack_col0.int or
            flat_row1 != pack_row1.int or flat_col1 != pack_col1.int:
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
    pack_row0, pack_col0, pack_row1, pack_col1, pack_row2, pack_col2: uint8
    flat_i: int
    mismatches = 0
    total = 0

  # Test all valid combinations
  for row0 in countup(Row):
    for col0 in countup(Col):
      for row1 in countup(Row):
        for col1 in countup(Col):
          for row2 in countup(Row):
            for col2 in countup(Col):
              inc total

              # Original flattened method
              flatTri(row0.int, col0.int, row1.int, col1.int, row2.int, col2.int, flat_i)
              unflatTri(flat_i, flat_row0, flat_col0, flat_row1, flat_col1, flat_row2, flat_col2)

              # New bit packed method
              let packed = packTri(row0, col0, row1, col1, row2, col2)
              unpackTri(packed, pack_row0, pack_col0, pack_row1, pack_col1, pack_row2, pack_col2)

              # Compare
              if flat_row0 != pack_row0.int or flat_col0 != pack_col0.int or
                flat_row1 != pack_row1.int or flat_col1 != pack_col1.int or
                flat_row2 != pack_row2.int or flat_col2 != pack_col2.int:
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
    pack_row0, pack_col0, pack_row1, pack_col1: uint8
    pack_row2, pack_col2, pack_row3, pack_col3: uint8
    flat_i: int
    mismatches = 0
    total = 0

  # Test subset of positions for demonstration
  for row0 in countup(Row):
    for col0 in countup(Col):
      for row1 in countup(Row):
        for col1 in countup(Col):
          for row2 in countup(Row):
            for col2 in countup(Col):
              for row3 in countup(Row):
                for col3 in countup(Col):
                  inc total

                  # Original flattened method
                  flatQuad(row0.int, col0.int, row1.int, col1.int, row2.int, col2.int, row3.int, col3.int, flat_i)
                  unflatQuad(flat_i, flat_row0, flat_col0, flat_row1, flat_col1,
                            flat_row2, flat_col2, flat_row3, flat_col3)

                  # New bit packed method
                  let packed = packQuad(row0, col0, row1, col1, row2, col2, row3, col3)
                  unpackQuad(packed, pack_row0, pack_col0, pack_row1, pack_col1,
                            pack_row2, pack_col2, pack_row3, pack_col3)

                  # Compare results
                  if flat_row0 != pack_row0.int or flat_col0 != pack_col0.int or
                      flat_row1 != pack_row1.int or flat_col1 != pack_col1.int or
                      flat_row2 != pack_row2.int or flat_col2 != pack_col2.int or
                      flat_row3 != pack_row3.int or flat_col3 != pack_col3.int:
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
