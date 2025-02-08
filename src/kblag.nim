import os, strutils, tables, sets, options, logging, times, math, sequtils, algorithm

include global, objects, util, log, fingerUtils, io, bigramAnalysis, trigramAnalysis, quadgramAnalysis, skipgramAnalysis, stats, analyze

proc main() =
  # Load fingermap from config file first
  var fingerMap = loadFingerMap("config.json")

  # Initialize the stats with the fingerMap
  initializeStats(fingerMap)

  info("Reading corpus")
  readCorpus("monkey0-7_IanDouglas")

  info("Normalizing corpus")
  normalizeCorpus()

  info("Reading and assigning scoring weights")
  readWeights("default")

  info("Cleaning stats")
  cleanStats()

  # Analyze layout
  analyzeLayout(fingerMap)


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

]#
