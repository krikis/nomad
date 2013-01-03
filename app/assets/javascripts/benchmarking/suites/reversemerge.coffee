suite = @reverseMerge = new Suite
  name:      'reversemerge'
  container: 'tab3'
  title:     'Structured Content Diff vs. Merged Diff Object'
  subtitle:  'Performance of data versioning and reconciliation'
  # benchRuns: 1
  # maxRuns:   1
  
suite.bench
  category: 'structured'
  series:   'reconcile(37%)'
  setup:    Benches.  setupStructRebase37
  before:   Benches. beforeStructRebase37
  test:     Benches.       structRebase37
  seeds:    [13,21,18,24,31,26,22,33,26,34,19,16,20,20,13,18,31,20,19,18,25,20,16,32,13,20,14,15,27,31]

suite.bench
  category: 'merged'
  series:   'reconcile(37%)'
  setup:    Benches.  setupMergeRebase37
  before:   Benches. beforeMergeRebase37
  test:     Benches.       mergeRebase37
  seeds:    [3,5,5,5,5,8,5,3,3,6,5,4,3,5,5,4,2,4,4,4,5,4,8,6,10,5,6,3,7,4]

suite.bench
  category: 'structured'
  series:   'version(37%)'
  setup:    Benches.  setupStructAddVersion37
  before:   Benches. beforeStructAddVersion37
  test:     Benches.       structAddVersion37
  seeds:    [46,21,37,30,56,42,33,36,21,28,18,22,28,31,41,39,35,42,26,11,15,29,35,32,31,53,46,49,41,24]

suite.bench
  category: 'merged'
  series:   'version(37%)'
  setup:    Benches.  setupMergeAddVersion37
  before:   Benches. beforeMergeAddVersion37
  test:     Benches.       mergeAddVersion37
  seeds:    [1,1,1,1,2,1,1,1,1,1,2,1,1,1,1,1,1,2,1,1,1,1,1,1,1,2,2,1,1,1]

suite.bench
  category: 'structured'
  series:   'reconcile(25%)'
  setup:    Benches.  setupStructRebase25
  before:   Benches. beforeStructRebase25
  test:     Benches.       structRebase25
  seeds:    [10,15,14,15,11,11,8,10,13,7,8,9,10,15,19,14,7,10,15,9,9,13,15,11,7,13,6,5,6,10]

suite.bench
  category: 'merged'
  series:   'reconcile(25%)'
  setup:    Benches.  setupMergeRebase25
  before:   Benches. beforeMergeRebase25
  test:     Benches.       mergeRebase25
  seeds:    [4,3,2,3,1,1,2,3,2,2,2,2,2,2,4,3,3,3,1,4,2,2,2,3,2,2,2,1,3,4]

suite.bench
  category: 'structured'
  series:   'version(25%)'
  setup:    Benches.  setupStructAddVersion25
  before:   Benches. beforeStructAddVersion25
  test:     Benches.       structAddVersion25
  seeds:    [9,15,21,16,12,12,8,14,9,6,11,9,8,15,21,19,17,13,13,11,9,13,10,13,10,12,19,13,10,9]

suite.bench
  category: 'merged'
  series:   'version(25%)'
  setup:    Benches.  setupMergeAddVersion25
  before:   Benches. beforeMergeAddVersion25
  test:     Benches.       mergeAddVersion25
  seeds:    [1,1,1,1,1,1,1,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2]

suite.bench
  category: 'structured'
  series:   'reconcile(12%)'
  setup:    Benches.  setupStructRebase12
  before:   Benches. beforeStructRebase12
  test:     Benches.       structRebase12
  seeds:    [4,2,3,4,3,3,6,3,2,3,8,4,2,4,3,6,4,3,3,3,3,3,4,4,2,6,5,6,2,6]

suite.bench
  category: 'merged'
  series:   'reconcile(12%)'
  setup:    Benches.  setupMergeRebase12
  before:   Benches. beforeMergeRebase12
  test:     Benches.       mergeRebase12
  seeds:    [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,0,1,1,1,0,1,1,1]

suite.bench
  category: 'structured'
  series:   'version(12%)'
  setup:    Benches.  setupStructAddVersion12
  before:   Benches. beforeStructAddVersion12
  test:     Benches.       structAddVersion12
  seeds:    [4,6,3,4,3,2,3,4,4,4,1,3,2,4,5,2,7,6,3,4,4,2,2,3,5,3,4,5,4,2]

suite.bench
  category: 'merged'
  series:   'version(12%)'
  setup:    Benches.  setupMergeAddVersion12
  before:   Benches. beforeMergeAddVersion12
  test:     Benches.       mergeAddVersion12
  seeds:    [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1]

# suite.bench
#   category: 'structured'
#   series:   'reconcile(6)'
#   setup:    Benches.  setupStructRebase6
#   before:   Benches. beforeStructRebase6
#   test:     Benches.       structRebase6
#   seeds:    [103,95,96,95,98,94,95,95,95,95,94,99,94,95,95,95,95,95,95,96,95,94,99,97]
# 
# suite.bench
#   category: 'merged'
#   series:   'reconcile(6)'
#   setup:    Benches.  setupMergeRebase6
#   before:   Benches. beforeMergeRebase6
#   test:     Benches.       mergeRebase6
#   seeds:    [109,111,111,108,108,109,107,112,108,108,109,114,109,111,109,111,109,112,109,111,108,110,110,111]
# 
# suite.bench
#   category: 'structured'
#   series:   'version(6)'
#   setup:    Benches.  setupStructAddVersion6
#   before:   Benches. beforeStructAddVersion6
#   test:     Benches.       structAddVersion6
#   seeds:    [82,83,84,80,80,80,79,80,80,80,80,79,81,81,81,80,83,80,81,86,80,80,80,84]
# 
# suite.bench
#   category: 'merged'
#   series:   'version(6)'
#   setup:    Benches.  setupMergeAddVersion6
#   before:   Benches. beforeMergeAddVersion6
#   test:     Benches.       mergeAddVersion6
#   seeds:    [2,2,1,1,2,2,2,2,2,2,2,1,2,2,2,2,1,2,2,2,2,2,2,2]
# 
# suite.bench
#   category: 'structured'
#   series:   'reconcile(3)'
#   setup:    Benches.  setupStructRebase3
#   before:   Benches. beforeStructRebase3
#   test:     Benches.       structRebase3
#   seeds:    [42,41,43,44,41,41,41,41,41,43,41,44,44,42,41,41,43,41,41,44,41,41,41,41]
# 
# suite.bench
#   category: 'merged'
#   series:   'reconcile(3)'
#   setup:    Benches.  setupMergeRebase3
#   before:   Benches. beforeMergeRebase3
#   test:     Benches.       mergeRebase3
#   seeds:    [31,32,29,29,29,29,29,29,29,29,29,35,32,31,32,31,32,30,33,29,29,30,29,29]
# 
# suite.bench
#   category: 'structured'
#   series:   'version(3)'
#   setup:    Benches.  setupStructAddVersion3
#   before:   Benches. beforeStructAddVersion3
#   test:     Benches.       structAddVersion3
#   seeds:    [37,36,35,34,34,34,35,34,37,34,35,36,35,36,34,36,35,36,37,36,34,36,35,36]
# 
# suite.bench
#   category: 'merged'
#   series:   'version(3)'
#   setup:    Benches.  setupMergeAddVersion3
#   before:   Benches. beforeMergeAddVersion3
#   test:     Benches.       mergeAddVersion3
#   seeds:    [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
# 
# suite.bench
#   category: 'structured'
#   series:   'reconcile(1)'
#   setup:    Benches.  setupStructRebase1
#   before:   Benches. beforeStructRebase1
#   test:     Benches.       structRebase1
#   seeds:    [19,18,19,19,20,20,21,20,18,18,19,19,19,18,18,19,19,19,19,19,19,19,20,19]
# 
# suite.bench
#   category: 'merged'
#   series:   'reconcile(1)'
#   setup:    Benches.  setupMergeRebase1
#   before:   Benches. beforeMergeRebase1
#   test:     Benches.       mergeRebase1
#   seeds:    [6,6,7,9,9,9,11,11,12,7,6,6,6,6,6,6,6,6,6,6,6,6,6,6]
# 
# suite.bench
#   category: 'structured'
#   series:   'version(1)'
#   setup:    Benches.  setupStructAddVersion1
#   before:   Benches. beforeStructAddVersion1
#   test:     Benches.       structAddVersion1
#   seeds:    [15,15,17,16,21,20,19,19,19,15,16,15,15,15,15,15,15,15,16,16,15,15,16,16]
# 
# suite.bench
#   category: 'merged'
#   series:   'version(1)'
#   setup:    Benches.  setupMergeAddVersion1
#   before:   Benches. beforeMergeAddVersion1
#   test:     Benches.       mergeAddVersion1
#   seeds:    [0,1,1,1,0,1,1,0,0,1,0,1,1,1,1,0,1,0,1,1,1,1,1,1]

