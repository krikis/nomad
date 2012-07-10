#= require_tree ./support
#= require_tree ./benches
#= require_self

preSyncCreateBench = new Bench
  name:    'presync_create'
  setup:   Benches.  setupPreSyncCreate
  before:  Benches. beforePreSyncCreate
  test:    Benches.       preSyncCreate
  after:   Benches.  afterPreSyncCreate
  cleanup: Benches.cleanupPreSyncCreate

$('#preSyncCreate').click ->
  preSyncCreateBench.run(@)

syncCreateBench = new Bench
  name:    'sync_create'
  setup:   Benches.  setupSyncCreate
  before:  Benches. beforeSyncCreate
  test:    Benches.       syncCreate
  after:   Benches.  afterSyncCreate
  cleanup: Benches.cleanupSyncCreate

$('#syncCreate').click ->
  syncCreateBench.run(@)
