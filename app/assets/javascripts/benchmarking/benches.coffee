#= require_tree ./support
#= require_tree ./benches
#= require_self

@barChart = new Highcharts.Chart @barChartConfig

suite = @suite = new Suite

suite.bench
  category: 'preSync'
  series:   'create'
  setup:    Benches.  setupPreSyncCreate
  before:   Benches. beforePreSyncCreate
  test:     Benches.       preSyncCreate
  after:    Benches.  afterPreSyncCreate
  cleanup:  Benches.cleanupPreSyncCreate
  chart:    @barChart

suite.bench 
  category: 'sync'
  series:   'create'
  setup:    Benches.  setupSyncCreate
  before:   Benches. beforeSyncCreate
  test:     Benches.       syncCreate
  after:    Benches.  afterSyncCreate
  cleanup:  Benches.cleanupSyncCreate
  chart:    @barChart

suite.bench
  category: 'preSync'
  series:   'update'
  setup:    Benches.  setupPreSyncUpdate
  before:   Benches. beforePreSyncUpdate
  test:     Benches.       preSyncUpdate
  after:    Benches.  afterPreSyncUpdate
  cleanup:  Benches.cleanupPreSyncUpdate
  chart:    @barChart

suite.bench 
  category: 'sync'
  series:   'update'
  setup:    Benches.  setupSyncUpdate
  before:   Benches. beforeSyncUpdate
  test:     Benches.       syncUpdate
  after:    Benches.  afterSyncUpdate
  cleanup:  Benches.cleanupSyncUpdate
  chart:    @barChart

$('#run').click ->
  suite.run(@)
