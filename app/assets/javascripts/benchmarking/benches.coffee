#= require_tree ./support
#= require_tree ./benches
#= require_self

@barChart = new Highcharts.Chart @barChartConfig

suite = @suite = new Suite
  measure:   'median'
  benchData: 'loremIpsum70KB'

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
  
suite.bench  
  category: 'preSync'
  series:   'conflict'
  setup:    Benches.  setupPreSyncConflict
  before:   Benches. beforePreSyncConflict
  test:     Benches.       preSyncConflict
  after:    Benches.  afterPreSyncConflict
  cleanup:  Benches.cleanupPreSyncConflict
  chart:    @barChart
  
suite.bench
  category: 'sync'
  series:   'conflict'
  setup:    Benches.  setupSyncConflict
  before:   Benches. beforeSyncConflict
  test:     Benches.       syncConflict
  after:    Benches.  afterSyncConflict
  cleanup:  Benches.cleanupSyncConflict
  chart:    @barChart

$('#run').click ->
  suite.run(@)
  
  
  
  
  