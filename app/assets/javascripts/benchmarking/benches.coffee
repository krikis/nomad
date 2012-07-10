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

$('#run').click ->
  suite.run(@)
