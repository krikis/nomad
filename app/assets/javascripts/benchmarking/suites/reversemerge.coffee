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
  seeds:    [52,50,49,50,55,50,49,52,49,49,52,50,50,54,49,50,50,49,50,52]

suite.bench
  category: 'merged'
  series:   'reconcile(6)'
  setup:    Benches.  setupMergeRebase6
  before:   Benches. beforeMergeRebase6
  test:     Benches.       mergeRebase6
  seeds:    [13,17,14,13,16,13,14,16,13,13,17,13,13,15,13,13,16,13,13,16]

suite.bench
  category: 'structured'
  series:   'version(6)'
  setup:    Benches.  setupStructAddVersion6
  before:   Benches. beforeStructAddVersion6
  test:     Benches.       structAddVersion6
  seeds:    [41,38,37,38,39,38,38,38,38,37,38,38,37,38,41,38,42,38,38,39]

suite.bench
  category: 'merged'
  series:   'version(6)'
  setup:    Benches.  setupMergeAddVersion6
  before:   Benches. beforeMergeAddVersion6
  test:     Benches.       mergeAddVersion6
  seeds:    [1,1,2,1,2,1,2,1,2,1,1,1,1,1,2,1,2,2,1,2]

suite.bench
  category: 'structured'
  series:   'reconcile(3)'
  setup:    Benches.  setupStructRebase3
  before:   Benches. beforeStructRebase3
  test:     Benches.       structRebase3
  seeds:    [23,23,24,23,23,26,23,23,23,23,23,26,23,23,25,23,23,25,23,23]

suite.bench
  category: 'merged'
  series:   'reconcile(3)'
  setup:    Benches.  setupMergeRebase3
  before:   Benches. beforeMergeRebase3
  test:     Benches.       mergeRebase3
  seeds:    [13,13,18,13,13,17,13,13,16,13,13,17,13,13,15,13,13,16,13,13]

suite.bench
  category: 'structured'
  series:   'version(3)'
  setup:    Benches.  setupStructAddVersion3
  before:   Benches. beforeStructAddVersion3
  test:     Benches.       structAddVersion3
  seeds:    [19,17,19,17,17,17,17,17,18,17,17,17,17,17,17,17,17,18,17,17]

suite.bench
  category: 'merged'
  series:   'version(3)'
  setup:    Benches.  setupMergeAddVersion3
  before:   Benches. beforeMergeAddVersion3
  test:     Benches.       mergeAddVersion3
  seeds:    [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]

