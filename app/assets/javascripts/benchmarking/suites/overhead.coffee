suite = @overhead = new Suite
  name:      'overhead'
  container: 'tab3'
  title:     'Serialized Data vs. Attribute Oriented Approach'
  subtitle:  'Performance of recording updates and reconciliation'
  # benchRuns: 1
  # maxRuns:   1

suite.bench
  category: 'serialized'
  series:   'reconcile(37%)'
  setup:    Benches.setupReconcileOverhead
  setupOpts:
    versioning: 'structured_content_diff'
  before:   Benches.beforeReconcileOverhead
  beforeOpts:
    changeRate: 0.375
  test:     Benches.reconcileOverhead
  seeds:    [10,31,13,18,13,16,14,30,24,18,22,26,21,18,16,21,17,15,9,20,19,17,15,29,22,14,23,21,18,14,16,26,22,27,16,32,24,31,32,26,18,21,20,10,20,12,18,26]

suite.bench
  category: 'attributes'
  series:   'reconcile(37%)'
  setup:    Benches.setupReconcileOverhead
  before:   Benches.beforeReconcileOverhead
  beforeOpts:
    changeRate: 0.375
  test:     Benches.reconcileOverhead
  seeds:    [4,3,5,7,6,6,5,7,5,6,6,6,3,5,4,7,6,6,5,7,5,5,4,8,7,5,10,5,6,4,6,2,3,4,3,2,6,7,5,5,5,3,6,4,4,5,5,7]

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
  seeds:    [39,35,41,38,28,37,32,37,47,35,25,24,22,25,20,20,29,15,41,34,34,34,24,31,22,35,37,40,42,37,28,41,34,21,41,31,13,32,20,22,13,45,51,35,20,20,41,24]

suite.bench
  category: 'attributes'
  series:   'record(37%)'
  setup:    Benches.setupRecordOverhead
  before:   Benches.beforeRecordOverhead
  test:     Benches.recordOverhead
  testOpts:
    changeRate: 0.375
  seeds:    [2,1,1,1,1,2,1,1,2,1,1,1,1,1,1,2,2,2,1,2,1,2,2,2,1,1,1,2,1,1,2,1,2,1,1,2,1,1,1,1,1,1,1,1,1,1,2,1]

suite.bench
  category: 'serialized'
  series:   'reconcile(25%)'
  setup:    Benches.setupReconcileOverhead
  setupOpts:
    versioning: 'structured_content_diff'
  before:   Benches.beforeReconcileOverhead
  beforeOpts:
    changeRate: 0.25
  test:     Benches.reconcileOverhead
  seeds:    [10,10,9,7,15,19,10,8,12,18,10,15,9,12,24,8,11,13,26,7,8,13,20,7,7,7,13,11,17,15,13,8,6,7,8,13,10,18,14,9,9,11,17,10,15,9,14,7]

suite.bench
  category: 'attributes'
  series:   'reconcile(25%)'
  setup:    Benches.setupReconcileOverhead
  before:   Benches.beforeReconcileOverhead
  beforeOpts:
    changeRate: 0.25
  test:     Benches.reconcileOverhead
  seeds:    [2,3,3,1,2,3,2,3,2,2,4,2,4,2,4,2,2,1,2,3,1,3,3,2,3,4,3,1,3,4,3,3,1,2,2,3,3,1,3,2,2,2,6,4,3,3,2,2]

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
  seeds:    [15,8,14,11,14,10,16,14,16,11,15,21,19,13,17,13,12,9,19,20,29,18,9,21,14,21,12,20,11,8,9,14,11,10,14,9,9,19,17,14,9,9,15,21,18,9,19,9]

suite.bench
  category: 'attributes'
  series:   'record(25%)'
  setup:    Benches.setupRecordOverhead
  before:   Benches.beforeRecordOverhead
  test:     Benches.recordOverhead
  testOpts:
    changeRate: 0.25
  seeds:    [1,1,1,1,1,1,1,1,1,2,3,2,1,1,1,2,1,1,2,1,1,1,1,1,1,1,1,2,1,1,1,1,1,1,1,2,1,2,1,1,1,1,1,1,1,1,1,1]

suite.bench
  category: 'serialized'
  series:   'reconcile(12%)'
  setup:    Benches.setupReconcileOverhead
  setupOpts:
    versioning: 'structured_content_diff'
  before:   Benches.beforeReconcileOverhead
  beforeOpts:
    changeRate: 0.125
  test:     Benches.reconcileOverhead
  seeds:    [5,4,5,2,6,4,6,8,5,4,2,4,2,3,2,3,4,4,4,4,6,6,6,3,5,5,2,4,2,3,4,1,3,3,2,3,6,7,5,4,3,4,3,3,2,4,2,2]

suite.bench
  category: 'attributes'
  series:   'reconcile(12%)'
  setup:    Benches.setupReconcileOverhead
  before:   Benches.beforeReconcileOverhead
  beforeOpts:
    changeRate: 0.125
  test:     Benches.reconcileOverhead
  seeds:    [1,1,1,0,1,0,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,1,1,0,0,1,1,1,1,1,0,1,0,1,1,1,1,1,0,1,1,1,1,1,1,1,1]

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
  seeds:    [2,2,5,3,2,3,10,3,5,5,2,2,3,3,8,1,4,3,2,3,3,3,3,3,8,9,3,2,6,6,4,3,3,5,3,3,4,5,2,3,2,6,2,4,3,9,3,3]

suite.bench
  category: 'attributes'
  series:   'record(12%)'
  setup:    Benches.setupRecordOverhead
  before:   Benches.beforeRecordOverhead
  test:     Benches.recordOverhead
  testOpts:
    changeRate: 0.125
  seeds:    [0,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1]

