suite = @preSync = new Suite
  name:      'presync'
  container: 'tab1'
  title:     'Preventive Reconciliation vs. Traditional Synchronization'
  subtitle:  'Duration of network communication for different sync operations'
  benchData: 'data280KB'
  benchRuns: 4
  timeout:   10000

suite.bench
  category: 'preSync'
  series:   'create'
  setup:    Benches.  setupPreSyncCreate
  before:   Benches. beforePreSyncCreate
  test:     Benches.       preSyncCreate
  after:    Benches.  afterPreSyncCreate
  cleanup:  Benches.cleanupPreSyncCreate
  seeds:    [3656,3657,3662,3665,3730,3738,3739,3742,3746,3756,3844,3850,3853,3920,4214,4254,4254,4255,4255,4255,4255,4257,4367,4409]

suite.bench
  category: 'sync'
  series:   'create'
  setup:    Benches.  setupSyncCreate
  before:   Benches. beforeSyncCreate
  test:     Benches.       syncCreate
  after:    Benches.  afterSyncCreate
  cleanup:  Benches.cleanupSyncCreate
  seeds:    [3387,3389,3394,3403,3410,3412,3412,3416,3427,3428,3430,3430,3432,3434,3455,3459,3482,3774,4030,4032,4037,4043,4046,4046]

suite.bench
  category: 'preSync'
  series:   'update'
  setup:    Benches.  setupPreSyncUpdate
  before:   Benches. beforePreSyncUpdate
  test:     Benches.       preSyncUpdate
  after:    Benches.  afterPreSyncUpdate
  cleanup:  Benches.cleanupPreSyncUpdate
  seeds:    [3501,3547,3629,3640,3647,3650,3652,3684,3686,3695,3707,3733,3741,3746,3914,3920,4083,4255,4255,4255,4255,4255,4263,4505]

suite.bench
  category: 'sync'
  series:   'update'
  setup:    Benches.  setupSyncUpdate
  before:   Benches. beforeSyncUpdate
  test:     Benches.       syncUpdate
  after:    Benches.  afterSyncUpdate
  cleanup:  Benches.cleanupSyncUpdate
  seeds:    [3527,3549,3581,3604,3612,3615,3615,3624,3625,3653,3667,3707,3766,3836,3889,3942,4036,4037,4037,4038,4286,4291,4299,4308]

suite.bench
  category: 'preSync'
  series:   'conflict'
  setup:    Benches.  setupPreSyncConflict
  before:   Benches. beforePreSyncConflict
  test:     Benches.       preSyncConflict
  after:    Benches.  afterPreSyncConflict
  cleanup:  Benches.cleanupPreSyncConflict
  seeds:    [3398,3420,3420,3426,3428,3429,3438,3447,3459,3461,3466,3492,3494,3496,3502,3757,3881,4004,4005,4005,4005,4005,4005,4255]

suite.bench
  category: 'sync'
  series:   'conflict'
  setup:    Benches.  setupSyncConflict
  before:   Benches. beforeSyncConflict
  test:     Benches.       syncConflict
  after:    Benches.  afterSyncConflict
  cleanup:  Benches.cleanupSyncConflict
  seeds:    [6187,6203,6210,6230,6232,6240,6242,6257,6264,6267,6282,6316,6321,6328,6330,7036,7036,7037,7040,7045,7046,7047,7048,7097]
