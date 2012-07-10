#= require_tree ./support
#= require_tree ./benches
#= require_self

preSyncCreateBench = new Bench
  setup:   Benches.  setupPreSyncCreate
  before:  Benches. beforePreSyncCreate
  test:    Benches.       preSyncCreate
  after:   Benches.  afterPreSyncCreate
  cleanup: Benches.cleanupPreSyncCreate

$('#preSyncCreate').click ->
  preSyncCreateBench.run(@)

syncCreateBench = new Bench
  setup:   Benches.  setupSyncCreate
  before:  Benches. beforeSyncCreate
  test:    Benches.       syncCreate
  after:   Benches.  afterSyncCreate
  cleanup: Benches.cleanupSyncCreate

$('#syncCreate').click ->
  syncCreateBench.run(@)
