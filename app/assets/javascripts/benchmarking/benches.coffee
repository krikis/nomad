#= require_tree ./support
#= require_tree ./benches
#= require_self

bench = new Bench
  setup:   Benches.  setupSyncCreate
  before:  Benches. beforeSyncCreate
  test:    Benches.       syncCreate
  after:   Benches.  afterSyncCreate
  cleanup: Benches.cleanupSyncCreate

$('#run').click ->
  bench.run()
