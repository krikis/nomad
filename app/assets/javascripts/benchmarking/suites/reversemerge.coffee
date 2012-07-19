suite = @reverseMerge = new Suite
  name:      'reversemerge'
  container: 'tab2'
  title:     'Object Reverse Merge vs. Structured Content Diff'
  subtitle:  'Duration of object versioning and conflict resolution'
  # benchRuns: 1
  # maxRuns:   1

suite.bench
  category: 'merge'
  series:   'version'
  setup:    Benches.  setupMergeAddVersion
  before:   Benches. beforeMergeAddVersion
  test:     Benches.       mergeAddVersion

suite.bench
  category: 'struct'
  series:   'version'
  setup:    Benches.  setupStructAddVersion
  before:   Benches. beforeStructAddVersion
  test:     Benches.       structAddVersion

suite.bench
  category: 'merge'
  series:   'rebase'
  setup:    Benches.  setupMergeRebase
  before:   Benches. beforeMergeRebase
  test:     Benches.       mergeRebase

suite.bench
  category: 'struct'
  series:   'rebase'
  setup:    Benches.  setupStructRebase
  before:   Benches. beforeStructRebase
  test:     Benches.       structRebase
  
  