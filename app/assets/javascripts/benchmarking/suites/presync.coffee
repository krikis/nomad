suite = @preSync = new Suite
  name:      'presync'
  container: 'tab1'
  title:     'Traditional Synchronization vs. Preventive Reconciliation'
  subtitle:  'Network latency during different sync operations'
  timeout:   60000

suite.bench
  category: 'traditional'
  series:   'resolve 210KB'
  data:     'data210KB'
  runs:     4
  setup:    Benches.  setupSyncConflict
  before:   Benches. beforeSyncConflict
  test:     Benches.       syncConflict
  after:    Benches.  afterSyncConflict
  cleanup:  Benches.cleanupSyncConflict
  seeds:    [4764,4860,4838,4824,4686,5001,5522,5022,6026,5272,5025,4831,5098,4937,4808,4962,4858,5021,5021,5028,4895,4780,4846,4963,5211,4868,4770,4807,5017,5015,5016,5019,5019,4893]

suite.bench
  category: 'preventive'
  series:   'resolve 210KB'
  data:     'data210KB'
  runs:     4
  setup:    Benches.  setupPreSyncConflict
  before:   Benches. beforePreSyncConflict
  test:     Benches.       preSyncConflict
  after:    Benches.  afterPreSyncConflict
  cleanup:  Benches.cleanupPreSyncConflict
  seeds:    [2735,2846,2760,2800,2745,3022,3254,3004,3004,3004,2856,2784,3206,3980,3053,2844,2846,3254,3255,2816,2746,2763,2741,3118,3004,2796,2779,2793,3004,3005,2808,3003,3004,2793]

suite.bench
  category: 'traditional'
  series:   'update 210KB'
  data:     'data210KB'
  runs:     4
  setup:    Benches.  setupSyncUpdate
  before:   Benches. beforeSyncUpdate
  test:     Benches.       syncUpdate
  after:    Benches.  afterSyncUpdate
  cleanup:  Benches.cleanupSyncUpdate
  seeds:    [2663,2749,2706,2729,3021,3275,3020,3022,3020,3023,2722,2706,3037,3773,3023,2731,2729,3024,3020,2710,2746,2696,2703,3019,3023,2694,2723,2729,3016,3013,3060,3015,3016,2907]

suite.bench
  category: 'preventive'
  series:   'update 210KB'
  data:     'data210KB'
  runs:     4
  setup:    Benches.  setupPreSyncUpdate
  before:   Benches. beforePreSyncUpdate
  test:     Benches.       preSyncUpdate
  after:    Benches.  afterPreSyncUpdate
  cleanup:  Benches.cleanupPreSyncUpdate
  seeds:    [2770,2880,2737,2769,3005,3254,3504,3004,3004,3004,2781,2758,3174,3504,3255,2809,2848,3004,3005,2893,2782,2790,2746,3003,3254,2759,2737,2814,3004,3004,3004,3004,3004,3239]

suite.bench
  category: 'traditional'
  series:   'create 210KB'
  data:     'data210KB'
  runs:     4
  setup:    Benches.  setupSyncCreate
  before:   Benches. beforeSyncCreate
  test:     Benches.       syncCreate
  after:    Benches.  afterSyncCreate
  cleanup:  Benches.cleanupSyncCreate
  seeds:    [2742,2751,2772,2756,3270,3016,3022,3023,3016,3020,2792,2714,3141,3518,3018,2727,2795,3021,3016,2723,2689,2773,2735,3265,3012,2685,2817,2739,3013,3011,3015,3016,3262,3018]

suite.bench
  category: 'preventive'
  series:   'create 210KB'
  data:     'data210KB'
  runs:     4
  setup:    Benches.  setupPreSyncCreate
  before:   Benches. beforePreSyncCreate
  test:     Benches.       preSyncCreate
  after:    Benches.  afterPreSyncCreate
  cleanup:  Benches.cleanupPreSyncCreate
  seeds:    [2780,2786,2817,2740,3005,3504,3004,3004,3004,3254,2790,2745,3263,3005,3005,2797,2814,3005,3255,2787,2853,2806,3036,3004,3004,2723,2768,3048,3004,3005,3004,3004,3013,3004]

suite.bench
  category: 'traditional'
  series:   'resolve 420KB'
  data:     'data420KB'
  runs:     2
  setup:    Benches.  setupSyncConflict
  before:   Benches. beforeSyncConflict
  test:     Benches.       syncConflict
  after:    Benches.  afterSyncConflict
  cleanup:  Benches.cleanupSyncConflict
  seeds:    []

suite.bench
  category: 'preventive'
  series:   'resolve 420KB'
  data:     'data420KB'
  runs:     2
  setup:    Benches.  setupPreSyncConflict
  before:   Benches. beforePreSyncConflict
  test:     Benches.       preSyncConflict
  after:    Benches.  afterPreSyncConflict
  cleanup:  Benches.cleanupPreSyncConflict
  seeds:    []

suite.bench
  category: 'traditional'
  series:   'update 420KB'
  data:     'data420KB'
  runs:     2
  setup:    Benches.  setupSyncUpdate
  before:   Benches. beforeSyncUpdate
  test:     Benches.       syncUpdate
  after:    Benches.  afterSyncUpdate
  cleanup:  Benches.cleanupSyncUpdate
  seeds:    []

suite.bench
  category: 'preventive'
  series:   'update 420KB'
  data:     'data420KB'
  runs:     2
  setup:    Benches.  setupPreSyncUpdate
  before:   Benches. beforePreSyncUpdate
  test:     Benches.       preSyncUpdate
  after:    Benches.  afterPreSyncUpdate
  cleanup:  Benches.cleanupPreSyncUpdate
  seeds:    []

suite.bench
  category: 'traditional'
  series:   'create 420KB'
  data:     'data420KB'
  runs:     2
  setup:    Benches.  setupSyncCreate
  before:   Benches. beforeSyncCreate
  test:     Benches.       syncCreate
  after:    Benches.  afterSyncCreate
  cleanup:  Benches.cleanupSyncCreate
  seeds:    []

suite.bench
  category: 'preventive'
  series:   'create 420KB'
  data:     'data420KB'
  runs:     2
  setup:    Benches.  setupPreSyncCreate
  before:   Benches. beforePreSyncCreate
  test:     Benches.       preSyncCreate
  after:    Benches.  afterPreSyncCreate
  cleanup:  Benches.cleanupPreSyncCreate
  seeds:    []

