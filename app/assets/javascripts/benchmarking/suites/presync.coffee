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
  seeds:    [4702,4775,5772,5328,5266,4774,4706,5016,4794,4722,5019,4770,4877,4741,4724,4692,4709,4637,4642,4698]

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
  seeds:    [3210,2738,3004,3505,3505,2716,2767,3505,2711,2694,3357,2740,2746,2721,2655,2664,2656,2637,2619,2615]

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
  seeds:    [3706,2629,3515,3517,3263,2629,2771,3015,2600,2619,2618,2649,2715,2620,2582,2562,2587,2594,2611,2598]

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
  seeds:    [3001,3284,3754,3514,3754,2721,3004,3004,2678,2678,2690,2652,2765,2736,2606,2618,2627,2611,2593,2615]

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
  seeds:    [3196,2741,2832,3061,3516,2648,3512,2635,2643,2672,2730,2708,2697,2682,2709,2650,2856,2600,2714,2613]

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
  seeds:    [3282,3004,2675,3284,3505,2672,3320,2718,2693,2676,2701,2672,2808,2687,2703,2758,2702,2626,2677,2608]

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
  seeds:    [9230,10039,9928,9600,9889,9334,9177,9367,9113,9124,9123,9078,9172,9150,9082,9102,9404,9072,9100,9053]

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
  seeds:    [5177,6016,6005,6007,6015,5019,5057,5088,5108,5045,5045,5142,5094,5057,5100,5018,5101,5108,4955,4949]

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
  seeds:    [5015,5031,5036,5530,5030,4948,4994,4972,4979,4972,4943,4997,5047,4976,4972,4966,4947,4900,4941,4917]

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
  seeds:    [5086,6005,6007,6009,5046,4986,5425,5031,4991,5004,4980,5128,5078,5048,5045,4975,4996,4952,5079,4906]

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
  seeds:    [4986,6024,6022,6039,4999,5036,5031,5063,5154,5149,4923,5120,5039,5062,5019,5058,4972,5006,5031,5067]

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
  seeds:    [5100,5711,5565,6007,5087,5111,5507,5138,5150,5516,5046,5201,5091,5229,5164,5058,4900,5075,4965,5028]

