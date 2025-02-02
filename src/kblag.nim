import os, strutils, tables, sets, options, logging, times, math, sequtils, algorithm

include global, objects, util, io, log, statsUtil, stats, analyze 

proc main() =
  initializeStats()

  info("Reading corpus")
  readCorpus("monkey0-7_IanDouglas")

  info("Normalizing corpus")
  normalizeCorpus()

  info("Reading and assigning scoring weights")
  readWeights("default")

  info("Cleaning stats")
  cleanStats()

  # Analyze layout
  analyzeLayout()

  #for name, stat in biStats:
  #  echo name, ": ", stat.weight


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
