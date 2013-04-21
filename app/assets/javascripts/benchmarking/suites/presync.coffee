suite = @preSync = new Suite
  name:      'presync'
  container: 'tab1'
  title:     'Traditional Synchronization vs. Preventive Reconciliation'
  subtitle:  'Network load during different synchronization operations'
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
  seeds:    [4845,4831,4822,4894,4908,4880,4874,4877,4903,6426,4971,4977,4880,4822,4860,4850,4816,4901,4896,4773]

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
  seeds:    [2843,2806,2831,2864,2895,2827,2833,2852,2874,2892,2865,2818,2824,2812,2809,2822,2901,2987,2840,2805]

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
  seeds:    [2509,2622,2555,2723,2617,2615,2653,2535,2715,2564,3140,2572,2598,2620,2690,2557,2591,2559,2503,2542]

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
  seeds:    [2608,2738,2562,2561,2585,2610,2653,2550,2557,2662,2730,2621,2573,2527,2705,2603,2526,2645,2618,2785]

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
  seeds:    [2590,2581,2733,2597,2592,2517,2614,2599,2519,2576,2557,2669,2501,2610,2549,2499,2569,2475,2554,2639]

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
  seeds:    [2645,2688,2623,2629,2582,2638,2702,2611,2579,2579,2636,2665,2540,2656,2676,2545,2623,2624,2555,2656]

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
  seeds:    [9511,9437,9426,9390,9485,9643,9464,9345,9665,9452,9455,9427,9396,9464,9438,9360,9436,9576,9336,9412]

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
  seeds:    [5304,5362,5374,5375,5342,5347,5338,5476,6022,5461,5445,5292,5284,5340,5294,5261,5354,5368,5299,5433]

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
  seeds:    [4796,4823,4858,4892,4864,4858,4809,4868,4807,4880,5010,4846,4787,4811,4814,4817,4905,4875,4758,4922]

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
  seeds:    [4873,4838,4892,4837,4980,4859,4915,4899,4857,4847,4861,4844,4828,4845,4900,4817,4844,4877,4863,4886]

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
  seeds:    [4814,4880,4906,4899,4855,4835,4902,4880,4946,4907,4897,4991,4784,4840,4821,4776,4865,4852,4784,4900]

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
  seeds:    [4908,5000,4872,5004,4944,4886,4937,4846,4918,4890,4918,4883,4851,4895,4839,4869,4843,4846,4891,4834]

