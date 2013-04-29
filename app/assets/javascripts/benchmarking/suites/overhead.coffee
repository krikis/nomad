suite = @overhead = new Suite
  name:      'overhead'
  container: 'tab3'
  title:     'Serialized Data vs. Attribute Oriented Approach'
  subtitle:  'Performance overhead of recording updates and resolving conflicts'
  # benchRuns: 1
  # maxRuns:   1

suite.bench
  category: 'serialized'
  series:   'resolve(37%)'
  setup:    Benches.setupResolveOverhead
  setupOpts:
    versioning: 'structured_content_diff'
  before:   Benches.beforeResolveOverhead
  beforeOpts:
    changeRate: 0.375
  test:     Benches.resolveOverhead
  seeds:    [14,20,19,23,18,22,20,14,37,20,41,36,25,14,26,22,19,28,16,17,24,20,7,11,37,25,15,14,17,11,13,26,16,15,18,17,14,18,18,16,17,10,14,13,30,13,26,28,20,13]

suite.bench
  category: 'attributes'
  series:   'resolve(37%)'
  setup:    Benches.setupResolveOverhead
  before:   Benches.beforeResolveOverhead
  beforeOpts:
    changeRate: 0.375
  test:     Benches.resolveOverhead
  seeds:    [5,6,6,3,5,3,4,5,4,4,4,4,6,6,4,4,4,6,4,7,4,4,7,5,6,3,7,6,5,6,7,5,6,4,4,6,5,5,7,7,8,4,9,3,5,4,4,4,5,4]

suite.bench
  category: 'serialized'
  series:   'record(37%)'
  setup:    Benches.setupRecordOverhead
  setupOpts:
    versioning: 'structured_content_diff'
  before:   Benches.beforeRecordOverhead
  test:     Benches.recordOverhead
  testOpts:
    changeRate: 0.375
  seeds:    [28,23,38,37,38,10,34,33,31,15,24,31,19,31,31,16,29,43,42,20,25,24,28,26,26,34,32,57,28,21,22,24,27,33,46,29,46,21,33,23,25,18,26,20,26,35,26,41,42,28]

suite.bench
  category: 'attributes'
  series:   'record(37%)'
  setup:    Benches.setupRecordOverhead
  before:   Benches.beforeRecordOverhead
  test:     Benches.recordOverhead
  testOpts:
    changeRate: 0.375
  seeds:    [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,1,3,1,1,3,1,1,1,1,1,1,1,1,1,2,1,1,1,1,1,1]

suite.bench
  category: 'serialized'
  series:   'resolve(25%)'
  setup:    Benches.setupResolveOverhead
  setupOpts:
    versioning: 'structured_content_diff'
  before:   Benches.beforeResolveOverhead
  beforeOpts:
    changeRate: 0.25
  test:     Benches.resolveOverhead
  seeds:    [10,23,17,15,22,13,11,9,12,10,10,10,11,17,11,11,14,13,12,17,8,12,12,9,7,20,9,12,10,15,15,14,12,8,11,13,16,15,10,13,16,9,11,12,17,9,8,13,7,10]

suite.bench
  category: 'attributes'
  series:   'resolve(25%)'
  setup:    Benches.setupResolveOverhead
  before:   Benches.beforeResolveOverhead
  beforeOpts:
    changeRate: 0.25
  test:     Benches.resolveOverhead
  seeds:    [1,3,3,3,3,5,2,5,4,2,3,2,2,3,2,2,3,2,2,2,2,2,2,3,4,3,2,2,6,4,2,2,3,2,2,7,2,3,3,3,2,2,2,3,2,4,3,2,1,1]

suite.bench
  category: 'serialized'
  series:   'record(25%)'
  setup:    Benches.setupRecordOverhead
  setupOpts:
    versioning: 'structured_content_diff'
  before:   Benches.beforeRecordOverhead
  test:     Benches.recordOverhead
  testOpts:
    changeRate: 0.25
  seeds:    [10,8,19,13,24,17,14,11,18,17,11,13,12,6,17,12,13,23,22,11,8,12,10,10,18,16,23,12,18,8,7,9,19,13,14,12,7,14,10,7,13,14,13,13,15,11,18,15,14,7]

suite.bench
  category: 'attributes'
  series:   'record(25%)'
  setup:    Benches.setupRecordOverhead
  before:   Benches.beforeRecordOverhead
  test:     Benches.recordOverhead
  testOpts:
    changeRate: 0.25
  seeds:    [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,1,1,1,1,1,1,1]

suite.bench
  category: 'serialized'
  series:   'resolve(12%)'
  setup:    Benches.setupResolveOverhead
  setupOpts:
    versioning: 'structured_content_diff'
  before:   Benches.beforeResolveOverhead
  beforeOpts:
    changeRate: 0.125
  test:     Benches.resolveOverhead
  seeds:    [6,6,3,5,5,3,6,2,3,9,4,7,3,5,5,4,7,2,5,3,4,3,3,3,4,3,2,3,4,5,3,3,4,3,7,2,6,3,7,5,4,4,3,4,6,4,3,3,2,9]

suite.bench
  category: 'attributes'
  series:   'resolve(12%)'
  setup:    Benches.setupResolveOverhead
  before:   Benches.beforeResolveOverhead
  beforeOpts:
    changeRate: 0.125
  test:     Benches.resolveOverhead
  seeds:    [1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,0,1,0,1,1,1,2,1,1,1,1,0,1,1,1,1,1,1,0,1,1,0,1,1,1,0,1,1,0,1,0,1,1,2,1]

suite.bench
  category: 'serialized'
  series:   'record(12%)'
  setup:    Benches.setupRecordOverhead
  setupOpts:
    versioning: 'structured_content_diff'
  before:   Benches.beforeRecordOverhead
  test:     Benches.recordOverhead
  testOpts:
    changeRate: 0.125
  seeds:    [4,6,6,1,2,3,3,2,2,5,3,6,5,2,4,4,6,3,2,2,3,4,3,2,4,5,5,3,2,4,3,4,2,4,2,3,8,5,2,3,5,3,3,2,2,2,2,4,2,2]

suite.bench
  category: 'attributes'
  series:   'record(12%)'
  setup:    Benches.setupRecordOverhead
  before:   Benches.beforeRecordOverhead
  test:     Benches.recordOverhead
  testOpts:
    changeRate: 0.125
  seeds:    [1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,0,0,1,1,0,1,1,1,0,1,1,1,1,1,1,0,1,1,1,1,0,1,1,1,1,1,1,1,1,1,1,0,1,1,1]

# strings & mods only

suite.bench
  category: 'serialized'
  series:   'resolve 37% (strings & mods only)'
  setup:    Benches.setupResolveOverhead
  setupOpts:
    versioning: 'structured_content_diff'
  before:   Benches.beforeResolveOverhead
  beforeOpts:
    changeRate: 0.375
    typeOdds: [0, 0, 1, 2]
    changeOdds: [0, 1, 0]
  test:     Benches.resolveOverhead
  seeds:    [36,29,22,44,29,33,34,44,35,26,16,40,39,31,22,19,36,17,34,24,33,24,29,31,23,31,29,31,23,45,44,33,26,41,29,34,23,33,33,43,27,22,24,24,31,24,43,40,36,23]

suite.bench
  category: 'attributes'
  series:   'resolve 37% (strings & mods only)'
  setup:    Benches.setupResolveOverhead
  before:   Benches.beforeResolveOverhead
  beforeOpts:
    changeRate: 0.375
    typeOdds: [0, 0, 1, 2]
    changeOdds: [0, 1, 0]
  test:     Benches.resolveOverhead
  seeds:    [13,10,10,14,12,10,12,15,11,16,8,12,13,10,9,12,9,18,12,10,12,11,13,9,9,12,13,11,10,11,9,12,11,11,10,12,12,12,15,10,10,10,12,8,10,11,9,12,12,7]

suite.bench
  category: 'serialized'
  series:   'record 37% (strings & mods only)'
  setup:    Benches.setupRecordOverhead
  setupOpts:
    versioning: 'structured_content_diff'
  before:   Benches.beforeRecordOverhead
  beforeOpts:
    typeOdds: [0, 0, 1, 2]
  test:     Benches.recordOverhead
  testOpts:
    changeRate: 0.375
    changeOdds: [0, 1, 0]
  seeds:    [56,39,43,50,45,36,52,42,43,49,37,45,32,33,41,54,60,47,58,30,34,42,52,44,34,45,48,25,48,40,39,33,45,49,34,39,53,62,34,49,33,37,46,48,61,33,47,52,46,47]

suite.bench
  category: 'attributes'
  series:   'record 37% (strings & mods only)'
  setup:    Benches.setupRecordOverhead
  before:   Benches.beforeRecordOverhead
  beforeOpts:
    typeOdds: [0, 0, 1, 2]
  test:     Benches.recordOverhead
  testOpts:
    changeRate: 0.375
    changeOdds: [0, 1, 0]
  seeds:    [1,1,1,1,1,1,2,1,1,1,1,3,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,1,1,1,1,1,1,1]

suite.bench
  category: 'serialized'
  series:   'resolve 25% (strings & mods only)'
  setup:    Benches.setupResolveOverhead
  setupOpts:
    versioning: 'structured_content_diff'
  before:   Benches.beforeResolveOverhead
  beforeOpts:
    changeRate: 0.25
    typeOdds: [0, 0, 1, 2]
    changeOdds: [0, 1, 0]
  test:     Benches.resolveOverhead
  seeds:    [23,13,13,16,13,13,17,13,17,17,8,17,12,12,15,15,21,9,14,16,21,19,7,23,18,23,14,13,14,10,11,20,14,8,23,14,12,12,15,14,13,21,16,13,13,13,15,17,8,17]

suite.bench
  category: 'attributes'
  series:   'resolve 25% (strings & mods only)'
  setup:    Benches.setupResolveOverhead
  before:   Benches.beforeResolveOverhead
  beforeOpts:
    changeRate: 0.25
    typeOdds: [0, 0, 1, 2]
    changeOdds: [0, 1, 0]
  test:     Benches.resolveOverhead
  seeds:    [7,7,6,7,5,3,5,6,4,4,7,4,7,5,6,4,7,5,4,5,7,9,4,4,5,6,4,4,5,5,4,5,7,4,5,5,4,4,4,6,4,5,4,5,4,5,5,6,9,4]

suite.bench
  category: 'serialized'
  series:   'record 25% (strings & mods only)'
  setup:    Benches.setupRecordOverhead
  setupOpts:
    versioning: 'structured_content_diff'
  before:   Benches.beforeRecordOverhead
  beforeOpts:
    typeOdds: [0, 0, 1, 2]
  test:     Benches.recordOverhead
  testOpts:
    changeRate: 0.25
    changeOdds: [0, 1, 0]
  seeds:    [14,19,12,17,16,15,13,12,17,18,16,12,11,14,21,10,16,17,12,14,15,10,11,13,17,14,20,15,13,13,22,14,19,26,19,13,15,12,12,18,19,19,16,9,16,11,11,13,13,18]

suite.bench
  category: 'attributes'
  series:   'record 25% (strings & mods only)'
  setup:    Benches.setupRecordOverhead
  before:   Benches.beforeRecordOverhead
  beforeOpts:
    typeOdds: [0, 0, 1, 2]
  test:     Benches.recordOverhead
  testOpts:
    changeRate: 0.25
    changeOdds: [0, 1, 0]
  seeds:    [1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]

suite.bench
  category: 'serialized'
  series:   'resolve 12% (strings & mods only)'
  setup:    Benches.setupResolveOverhead
  setupOpts:
    versioning: 'structured_content_diff'
  before:   Benches.beforeResolveOverhead
  beforeOpts:
    changeRate: 0.125
    typeOdds: [0, 0, 1, 2]
    changeOdds: [0, 1, 0]
  test:     Benches.resolveOverhead
  seeds:    [7,5,4,5,4,3,4,5,4,3,4,3,5,5,4,4,5,6,4,4,4,3,4,4,5,4,4,5,4,3,4,4,4,4,4,4,8,8,4,4,7,4,3,3,3,5,3,6,6,3]

suite.bench
  category: 'attributes'
  series:   'resolve 12% (strings & mods only)'
  setup:    Benches.setupResolveOverhead
  before:   Benches.beforeResolveOverhead
  beforeOpts:
    changeRate: 0.125
    typeOdds: [0, 0, 1, 2]
    changeOdds: [0, 1, 0]
  test:     Benches.resolveOverhead
  seeds:    [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,1,1,1,1,1,1,1,1,1,1,1,1]

suite.bench
  category: 'serialized'
  series:   'record 12% (strings & mods only)'
  setup:    Benches.setupRecordOverhead
  setupOpts:
    versioning: 'structured_content_diff'
  before:   Benches.beforeRecordOverhead
  beforeOpts:
    typeOdds: [0, 0, 1, 2]
  test:     Benches.recordOverhead
  testOpts:
    changeRate: 0.125
    changeOdds: [0, 1, 0]
  seeds:    [8,2,3,4,3,4,3,3,5,3,3,4,3,4,3,3,3,3,4,2,4,3,6,6,4,3,8,5,4,7,2,3,8,3,3,6,2,5,4,3,3,4,2,7,3,4,3,5,4,3]

suite.bench
  category: 'attributes'
  series:   'record 12% (strings & mods only)'
  setup:    Benches.setupRecordOverhead
  before:   Benches.beforeRecordOverhead
  beforeOpts:
    typeOdds: [0, 0, 1, 2]
  test:     Benches.recordOverhead
  testOpts:
    changeRate: 0.125
    changeOdds: [0, 1, 0]
  seeds:    [1,1,1,1,0,1,1,0,1,1,0,0,1,1,1,0,1,1,0,1,1,1,1,1,0,1,1,1,1,1,1,1,1,0,0,1,1,1,1,1,1,0,0,1,0,0,1,1,1,1]

