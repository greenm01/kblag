import os, strutils, tables, sets, options, logging, times, math, sequtils, algorithm, unicode

include global, objects, util, fingerUtils, io, bigramAnalysis, trigramAnalysis, quadgramAnalysis, skipgramAnalysis, stats, analyze, log

proc main() =

  #testBigramEquivalence()
  #testTrigramEquivalence()
  #testQuadgramEquivalence()

  # TODO: command line args
  var lang = "english"
  var corpus = "monkey0-7_IanDouglas"
  var layout = "hiyou"
  var config = "config"
  var weights = "benchmark"

  info "Reading language file"
  readLang(lang)

  info "Loading fingermap from config file"
  var fingerMap = readFingerMap(config)

  # Initialize the stats with the fingerMap
  initializeStats(fingerMap)

  #echo "foo ", validateFingerMap(fingerMap)

  info("Reading corpus")
  readCorpus(lang, corpus)

  info("Normalizing corpus")
  normalizeCorpus()

  info("Reading and assigning scoring weights")
  readWeights(weights)

  info("Cleaning stats")
  cleanStats()

  # Analyze layout
  analyzeLayout(layout, fingerMap)

  #echoFingerMap(fingerMap)

when isMainModule:
  main()

#[ NOTES:

nimble run -d:release --opt:speed -d:danger --passL:-s --cc:clang --mm:arc

# Log messages at different levels
#debug("This is a debug message")
#info("This is an info message")
#warn("This is a warning message")
#error("This is an error message")

# Log the corpus arrays
#logCharTable()
#logCorpusMono()
#logCorpusBi()
#logCorpusTri()
#logCorpusQuad()
#logCorpusSkip()
#logCharTable()
#echo layout.matrix
#echo linearMono
#echo layout.monoScore

TABLE OF THE 95 ASCII CHARACTER CODES

 32 space  48 0      64 @      80 P      96 `     112 p
 33 !      49 1      65 A      81 Q      97 a     113 q
 34 "      50 2      66 B      82 R      98 b     114 r
 35 #      51 3      67 C      83 S      99 c     115 s
 36 $      52 4      68 D      84 T     100 d     116 t
 37 %      53 5      69 E      85 U     101 e     117 u
 38 &      54 6      70 F      86 V     102 f     118 v
 39 '      55 7      71 G      87 W     103 g     119 w
 40 (      56 8      72 H      88 X     104 h     120 x
 41 )      57 9      73 I      89 Y     105 i     121 y
 42 *      58 :      74 J      90 Z     106 j     122 z
 43 +      59 ;      75 K      91 [     107 k     123 {
 44 ,      60 <      76 L      92 \     108 l     124 |
 45 -      61 =      77 M      93 ]     109 m     125 }
 46 .      62 >      78 N      94 ^     110 n     126 ~
 47 /      63 ?      79 O      95 _     111 o

]#
