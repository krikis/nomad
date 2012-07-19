suite = @reverseMerge = new Suite
  name:      'reversemerge'
  container: 'tab2'
  title:     'Object Reverse Merge vs. Structured Content Diff'
  subtitle:  'Duration of object versioning and conflict resolution'
  # benchRuns: 1
  # maxRuns:   1

suite.bench
  category: 'merge'
  series:   'version(3)'
  setup:    Benches.  setupMergeAddVersion3
  before:   Benches. beforeMergeAddVersion3
  test:     Benches.       mergeAddVersion3

suite.bench
  category: 'struct'
  series:   'version(3)'
  setup:    Benches.  setupStructAddVersion3
  before:   Benches. beforeStructAddVersion3
  test:     Benches.       structAddVersion3

suite.bench
  category: 'merge'
  series:   'rebase(3)'
  setup:    Benches.  setupMergeRebase3
  before:   Benches. beforeMergeRebase3
  test:     Benches.       mergeRebase3

suite.bench
  category: 'struct'
  series:   'rebase(3)'
  setup:    Benches.  setupStructRebase3
  before:   Benches. beforeStructRebase3
  test:     Benches.       structRebase3

suite.bench
  category: 'merge'
  series:   'version(6)'
  setup:    Benches.  setupMergeAddVersion6
  before:   Benches. beforeMergeAddVersion6
  test:     Benches.       mergeAddVersion6

suite.bench
  category: 'struct'
  series:   'version(6)'
  setup:    Benches.  setupStructAddVersion6
  before:   Benches. beforeStructAddVersion6
  test:     Benches.       structAddVersion6

suite.bench
  category: 'merge'
  series:   'rebase(6)'
  setup:    Benches.  setupMergeRebase6
  before:   Benches. beforeMergeRebase6
  test:     Benches.       mergeRebase6

suite.bench
  category: 'struct'
  series:   'rebase(6)'
  setup:    Benches.  setupStructRebase6
  before:   Benches. beforeStructRebase6
  test:     Benches.       structRebase6

