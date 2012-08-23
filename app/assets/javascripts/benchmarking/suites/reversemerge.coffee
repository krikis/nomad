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
  seeds:    [338,339,340,340,340,341,341,342,354]

suite.bench
  category: 'merged'
  series:   'reconcile(6)'
  setup:    Benches.  setupMergeRebase6
  before:   Benches. beforeMergeRebase6
  test:     Benches.       mergeRebase6
  seeds:    [150,150,150,151,151,152,154,154,155]

suite.bench
  category: 'structured'
  series:   'version(6)'
  setup:    Benches.  setupStructAddVersion6
  before:   Benches. beforeStructAddVersion6
  test:     Benches.       structAddVersion6
  seeds:    [307,307,308,309,310,311,312,315,345]

suite.bench
  category: 'merged'
  series:   'version(6)'
  setup:    Benches.  setupMergeAddVersion6
  before:   Benches. beforeMergeAddVersion6
  test:     Benches.       mergeAddVersion6
  seeds:    [3,3,3,4,4,4,4,4,4]

suite.bench
  category: 'structured'
  series:   'reconcile(3)'
  setup:    Benches.  setupStructRebase3
  before:   Benches. beforeStructRebase3
  test:     Benches.       structRebase3
  seeds:    [144,145,145,145,145,146,146,148,149]

suite.bench
  category: 'merged'
  series:   'reconcile(3)'
  setup:    Benches.  setupMergeRebase3
  before:   Benches. beforeMergeRebase3
  test:     Benches.       mergeRebase3
  seeds:    [149,150,151,151,152,152,153,155,157]

suite.bench
  category: 'structured'
  series:   'version(3)'
  setup:    Benches.  setupStructAddVersion3
  before:   Benches. beforeStructAddVersion3
  test:     Benches.       structAddVersion3
  seeds:    [129,129,130,130,130,131,132,133,135]

suite.bench
  category: 'merged'
  series:   'version(3)'
  setup:    Benches.  setupMergeAddVersion3
  before:   Benches. beforeMergeAddVersion3
  test:     Benches.       mergeAddVersion3
  seeds:    [2,2,2,2,2,2,2,2,4]

