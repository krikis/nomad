suite = @preSync = new Suite
  name:      'presync'
  container: 'tab1'
  title:     'Traditional Synchronization vs. Preventive Reconciliation'
  subtitle:  'Network latency during different sync operations'
  benchData: 'data210KB'
  benchRuns: 4
  timeout:   1000

suite.bench
  category: 'traditional'
  series:   'conflict'
  setup:    Benches.  setupSyncConflict
  before:   Benches. beforeSyncConflict
  test:     Benches.       syncConflict
  after:    Benches.  afterSyncConflict
  cleanup:  Benches.cleanupSyncConflict
  seeds:    [4653,4655,4683,4696,4700,4709,4728,4735,4737,4737,4748,4774,4818,4862,4977,5016,5021,5027,5272,5272,5340,5531]

suite.bench
  category: 'preventive'
  series:   'conflict'
  setup:    Benches.  setupPreSyncConflict
  before:   Benches. beforePreSyncConflict
  test:     Benches.       preSyncConflict
  after:    Benches.  afterPreSyncConflict
  cleanup:  Benches.cleanupPreSyncConflict
  seeds:    [2654,2680,2680,2701,2704,2711,2713,2719,2720,2722,2730,2735,2736,2736,2753,2762,2828,3004,3004,3004,3018,3022]

suite.bench
  category: 'traditional'
  series:   'update'
  setup:    Benches.  setupSyncUpdate
  before:   Benches. beforeSyncUpdate
  test:     Benches.       syncUpdate
  after:    Benches.  afterSyncUpdate
  cleanup:  Benches.cleanupSyncUpdate
  seeds:    [2556,2570,2579,2587,2597,2600,2600,2606,2612,2613,2613,2628,2642,2646,2737,3015,3019,3020,3021,3023,3034,3128]

suite.bench
  category: 'preventive'
  series:   'update'
  setup:    Benches.  setupPreSyncUpdate
  before:   Benches. beforePreSyncUpdate
  test:     Benches.       preSyncUpdate
  after:    Benches.  afterPreSyncUpdate
  cleanup:  Benches.cleanupPreSyncUpdate
  seeds:    [2623,2624,2631,2642,2646,2658,2659,2665,2675,2696,2696,2711,2723,2735,2989,3004,3005,3005,3013,3077,3505,3507]

suite.bench
  category: 'traditional'
  series:   'create'
  setup:    Benches.  setupSyncCreate
  before:   Benches. beforeSyncCreate
  test:     Benches.       syncCreate
  after:    Benches.  afterSyncCreate
  cleanup:  Benches.cleanupSyncCreate
  seeds:    [2594,2613,2614,2615,2617,2624,2628,2628,2633,2636,2638,2653,2658,2708,2721,3020,3020,3020,3022,3040,3129]

suite.bench
  category: 'preventive'
  series:   'create'
  setup:    Benches.  setupPreSyncCreate
  before:   Benches. beforePreSyncCreate
  test:     Benches.       preSyncCreate
  after:    Benches.  afterPreSyncCreate
  cleanup:  Benches.cleanupPreSyncCreate
  seeds:    [2597,2637,2651,2652,2655,2655,2661,2665,2668,2682,2686,2695,2779,2844,3004,3004,3004,3006,3009,3015]
