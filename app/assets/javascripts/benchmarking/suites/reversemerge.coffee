suite = @reverseMerge = new Suite
  name:      'reversemerge'
  container: 'tab3'
  title:     'Structured Content Diff vs. Merged Diff Object'
  subtitle:  'Performance of data versioning and reconciliation'
  # benchRuns: 1
  # maxRuns:   1
  
suite.bench
  category: 'structured'
  series:   'reconcile(50%)'
  setup:    Benches.  setupStructRebase50
  before:   Benches. beforeStructRebase50
  test:     Benches.       structRebase50
  seeds:    []

suite.bench
  category: 'merged'
  series:   'reconcile(50%)'
  setup:    Benches.  setupMergeRebase50
  before:   Benches. beforeMergeRebase50
  test:     Benches.       mergeRebase50
  seeds:    []

suite.bench
  category: 'structured'
  series:   'version(50%)'
  setup:    Benches.  setupStructAddVersion50
  before:   Benches. beforeStructAddVersion50
  test:     Benches.       structAddVersion50
  seeds:    []

suite.bench
  category: 'merged'
  series:   'version(50%)'
  setup:    Benches.  setupMergeAddVersion50
  before:   Benches. beforeMergeAddVersion50
  test:     Benches.       mergeAddVersion50
  seeds:    []

suite.bench
  category: 'structured'
  series:   'reconcile(25%)'
  setup:    Benches.  setupStructRebase25
  before:   Benches. beforeStructRebase25
  test:     Benches.       structRebase25
  seeds:    []

suite.bench
  category: 'merged'
  series:   'reconcile(25%)'
  setup:    Benches.  setupMergeRebase25
  before:   Benches. beforeMergeRebase25
  test:     Benches.       mergeRebase25
  seeds:    []

suite.bench
  category: 'structured'
  series:   'version(25%)'
  setup:    Benches.  setupStructAddVersion25
  before:   Benches. beforeStructAddVersion25
  test:     Benches.       structAddVersion25
  seeds:    []

suite.bench
  category: 'merged'
  series:   'version(25%)'
  setup:    Benches.  setupMergeAddVersion25
  before:   Benches. beforeMergeAddVersion25
  test:     Benches.       mergeAddVersion25
  seeds:    []

suite.bench
  category: 'structured'
  series:   'reconcile(12%)'
  setup:    Benches.  setupStructRebase12
  before:   Benches. beforeStructRebase12
  test:     Benches.       structRebase12
  seeds:    []

suite.bench
  category: 'merged'
  series:   'reconcile(12%)'
  setup:    Benches.  setupMergeRebase12
  before:   Benches. beforeMergeRebase12
  test:     Benches.       mergeRebase12
  seeds:    []

suite.bench
  category: 'structured'
  series:   'version(12%)'
  setup:    Benches.  setupStructAddVersion12
  before:   Benches. beforeStructAddVersion12
  test:     Benches.       structAddVersion12
  seeds:    []

suite.bench
  category: 'merged'
  series:   'version(12%)'
  setup:    Benches.  setupMergeAddVersion12
  before:   Benches. beforeMergeAddVersion12
  test:     Benches.       mergeAddVersion12
  seeds:    []

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

