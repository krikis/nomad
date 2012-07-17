suite = @threeWayMerge = new Suite
  name:      'threewaymerge'
  container: 'tab2'
  title:     'Object 3-Way Merge vs. Structured Content Diff'
  benchRuns: 1

suite.bench
  category: 'merge'
  series:   'addversion'
  setup:    Benches.  setupMergeAddVersion
  before:   Benches. beforeMergeAddVersion
  test:     Benches.       mergeAddVersion

suite.bench
  category: 'struct'
  series:   'addversion'
  setup:    Benches.  setupStructAddVersion
  before:   Benches. beforeStructAddVersion
  test:     Benches.       structAddVersion
  
  