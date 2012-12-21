suite = @reverseMerge = new Suite
  name:      'reversemerge'
  container: 'tab3'
  title:     'Structured Content Diff vs. Merged Diff Object'
  subtitle:  'Performance of data versioning and reconciliation'
  # benchRuns: 1
  # maxRuns:   1

suite.bench
  category: 'structured'
  series:   'reconcile(6)'
  setup:    Benches.  setupStructRebase6
  before:   Benches. beforeStructRebase6
  test:     Benches.       structRebase6
  seeds:    [56,50,49,49,49,49,49,52,50,50,54,49,49,52,49,49,53,49,49,53,50,50,51,49,49,49,50,52,49]

suite.bench
  category: 'merged'
  series:   'reconcile(6)'
  setup:    Benches.  setupMergeRebase6
  before:   Benches. beforeMergeRebase6
  test:     Benches.       mergeRebase6
  seeds:    [14,13,13,13,13,13,13,18,13,13,16,13,13,18,13,13,17,13,14,18,13,13,18,13,13,13,13,15,13]

suite.bench
  category: 'structured'
  series:   'version(6)'
  setup:    Benches.  setupStructAddVersion6
  before:   Benches. beforeStructAddVersion6
  test:     Benches.       structAddVersion6
  seeds:    [39,39,38,37,38,40,37,39,38,38,38,38,38,38,37,37,39,38,37,38,38,38,44,38,37,47,38,37,37]

suite.bench
  category: 'merged'
  series:   'version(6)'
  setup:    Benches.  setupMergeAddVersion6
  before:   Benches. beforeMergeAddVersion6
  test:     Benches.       mergeAddVersion6
  seeds:    [1,2,2,2,2,2,1,1,1,1,1,2,2,2,1,1,2,1,1,1,1,1,2,1,1,2,1,1,2]

suite.bench
  category: 'structured'
  series:   'reconcile(3)'
  setup:    Benches.  setupStructRebase3
  before:   Benches. beforeStructRebase3
  test:     Benches.       structRebase3
  seeds:    [23,23,23,23,23,23,23,23,29,23,23,25,23,23,27,23,23,29,23,23,30,25,23,23,23,26,23,23,27]

suite.bench
  category: 'merged'
  series:   'reconcile(3)'
  setup:    Benches.  setupMergeRebase3
  before:   Benches. beforeMergeRebase3
  test:     Benches.       mergeRebase3
  seeds:    [14,13,13,15,13,18,13,13,18,13,13,18,13,13,16,13,13,18,13,13,18,13,13,17,13,13,13,13,18]

suite.bench
  category: 'structured'
  series:   'version(3)'
  setup:    Benches.  setupStructAddVersion3
  before:   Benches. beforeStructAddVersion3
  test:     Benches.       structAddVersion3
  seeds:    [19,17,17,22,17,17,17,17,17,17,17,17,17,17,19,17,17,17,17,17,17,17,17,22,17,17,20,17,17]

suite.bench
  category: 'merged'
  series:   'version(3)'
  setup:    Benches.  setupMergeAddVersion3
  before:   Benches. beforeMergeAddVersion3
  test:     Benches.       mergeAddVersion3
  seeds:    [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]

suite.bench
  category: 'structured'
  series:   'reconcile(1)'
  setup:    Benches.  setupStructRebase1
  before:   Benches. beforeStructRebase1
  test:     Benches.       structRebase1
  seeds:    []

suite.bench
  category: 'merged'
  series:   'reconcile(1)'
  setup:    Benches.  setupMergeRebase1
  before:   Benches. beforeMergeRebase1
  test:     Benches.       mergeRebase1
  seeds:    []

suite.bench
  category: 'structured'
  series:   'version(1)'
  setup:    Benches.  setupStructAddVersion1
  before:   Benches. beforeStructAddVersion1
  test:     Benches.       structAddVersion1
  seeds:    []

suite.bench
  category: 'merged'
  series:   'version(1)'
  setup:    Benches.  setupMergeAddVersion1
  before:   Benches. beforeMergeAddVersion1
  test:     Benches.       mergeAddVersion1
  seeds:    []

