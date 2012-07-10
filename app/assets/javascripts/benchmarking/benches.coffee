#= require_tree ./support
#= require_tree ./benches
#= require_self

@barChart = new Highcharts.Chart @barChartConfig

preSyncCreateBench = new Bench
  category: 'preSync'
  series:   'create'
  setup:    Benches.  setupPreSyncCreate
  before:   Benches. beforePreSyncCreate
  test:     Benches.       preSyncCreate
  after:    Benches.  afterPreSyncCreate
  cleanup:  Benches.cleanupPreSyncCreate
  chart:    @barChart

$('#preSyncCreate').click ->
  preSyncCreateBench.run(@)

syncCreateBench = new Bench  
  category: 'sync'
  series:   'create'
  setup:    Benches.  setupSyncCreate
  before:   Benches. beforeSyncCreate
  test:     Benches.       syncCreate
  after:    Benches.  afterSyncCreate
  cleanup:  Benches.cleanupSyncCreate
  chart:    @barChart

$('#syncCreate').click ->
  syncCreateBench.run(@)
  
# @barChart.container = '#barChart'
