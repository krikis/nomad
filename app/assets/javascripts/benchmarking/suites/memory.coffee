suite = @memory = new Suite
  name:      'memory'
  container: 'tab2'
  title:     'Incremental vs. Merged Browser Log'
  subtitle:  'Memory footprint for recording local updates'
  baseline:  ->
  record:    ->
    @count += 1
    (JSON.stringify(@answer._versioning.patches).length / JSON.stringify(@answerOriginal).length) * 100
  unit:      '%'
  unitLong:  'Proportion of original data'
  # benchRuns: 1
  # maxRuns:   1

# 12% change

suite.bench
  category: 'incremental'
  series:   '15 updates (12%)'
  setup:    Benches.setupMemory
  setupOpts:
    versioning: 'structured_content_diff'
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.125
    nrOfUpdates: 15
  seeds:    [350,374,376,340,364,403,417,381,363,347,354,321,341,388,358,338,361,373,305,350]

suite.bench
  category: 'merged'
  series:   '15 updates (12%)'
  setup:    Benches.setupMemory
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.125
    nrOfUpdates: 15
  seeds:    [94,101,99,97,97,100,100,95,99,95,95,98,96,98,99,97,93,99,95,99]

suite.bench
  category: 'incremental'
  series:   '12 updates (12%)'
  setup:    Benches.setupMemory
  setupOpts:
    versioning: 'structured_content_diff'
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.125
    nrOfUpdates: 12
  seeds:    [350,374,376,340,364,403,417,381,363,347,354,321,341,388,358,338,361,373,305,350]

suite.bench
  category: 'merged'
  series:   '12 updates (12%)'
  setup:    Benches.setupMemory
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.125
    nrOfUpdates: 12
  seeds:    [94,101,99,97,97,100,100,95,99,95,95,98,96,98,99,97,93,99,95,99]

suite.bench
  category: 'incremental'
  series:   '9 updates (12%)'
  setup:    Benches.setupMemory
  setupOpts:
    versioning: 'structured_content_diff'
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.125
    nrOfUpdates: 9
  seeds:    [268,249,254,272,251,261,297,254,266,258,252,263,251,250,281,239,265,274,236,292]

suite.bench
  category: 'merged'
  series:   '9 updates (12%)'
  setup:    Benches.setupMemory
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.125
    nrOfUpdates: 9
  seeds:    [87,89,91,91,94,91,88,93,88,89,87,92,88,85,90,92,87,90,87,89]

suite.bench
  category: 'incremental'
  series:   '6 updates (12%)'
  setup:    Benches.setupMemory
  setupOpts:
    versioning: 'structured_content_diff'
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.125
    nrOfUpdates: 6
  seeds:    [181,177,201,226,191,170,169,162,178,174,146,173,170,169,175,150,174,170,186,169]

suite.bench
  category: 'merged'
  series:   '6 updates (12%)'
  setup:    Benches.setupMemory
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.125
    nrOfUpdates: 6
  seeds:    [75,73,70,81,72,68,77,66,75,73,75,77,68,70,78,79,72,74,73,75]

suite.bench
  category: 'incremental'
  series:   '3 updates (12%)'
  setup:    Benches.setupMemory
  setupOpts:
    versioning: 'structured_content_diff'
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.125
    nrOfUpdates: 3
  seeds:    [90,80,83,77,94,97,97,79,87,91,79,102,85,79,81,92,97,90,87,93]

suite.bench
  category: 'merged'
  series:   '3 updates (12%)'
  setup:    Benches.setupMemory
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.125
    nrOfUpdates: 3
  seeds:    [44,46,44,54,53,52,54,53,48,46,49,49,52,50,55,46,50,55,47,49]

# 25% change

suite.bench
  category: 'incremental'
  series:   '15 updates (25%)'
  setup:    Benches.setupMemory
  setupOpts:
    versioning: 'structured_content_diff'
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.25
    nrOfUpdates: 15
  seeds:    [350,374,376,340,364,403,417,381,363,347,354,321,341,388,358,338,361,373,305,350]

suite.bench
  category: 'merged'
  series:   '15 updates (25%)'
  setup:    Benches.setupMemory
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.25
    nrOfUpdates: 15
  seeds:    [94,101,99,97,97,100,100,95,99,95,95,98,96,98,99,97,93,99,95,99]

suite.bench
  category: 'incremental'
  series:   '12 updates (25%)'
  setup:    Benches.setupMemory
  setupOpts:
    versioning: 'structured_content_diff'
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.25
    nrOfUpdates: 12
  seeds:    [350,374,376,340,364,403,417,381,363,347,354,321,341,388,358,338,361,373,305,350]

suite.bench
  category: 'merged'
  series:   '12 updates (25%)'
  setup:    Benches.setupMemory
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.25
    nrOfUpdates: 12
  seeds:    [94,101,99,97,97,100,100,95,99,95,95,98,96,98,99,97,93,99,95,99]

suite.bench
  category: 'incremental'
  series:   '9 updates (25%)'
  setup:    Benches.setupMemory
  setupOpts:
    versioning: 'structured_content_diff'
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.25
    nrOfUpdates: 9
  seeds:    [268,249,254,272,251,261,297,254,266,258,252,263,251,250,281,239,265,274,236,292]

suite.bench
  category: 'merged'
  series:   '9 updates (25%)'
  setup:    Benches.setupMemory
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.25
    nrOfUpdates: 9
  seeds:    [87,89,91,91,94,91,88,93,88,89,87,92,88,85,90,92,87,90,87,89]

suite.bench
  category: 'incremental'
  series:   '6 updates (25%)'
  setup:    Benches.setupMemory
  setupOpts:
    versioning: 'structured_content_diff'
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.25
    nrOfUpdates: 6
  seeds:    [181,177,201,226,191,170,169,162,178,174,146,173,170,169,175,150,174,170,186,169]

suite.bench
  category: 'merged'
  series:   '6 updates (25%)'
  setup:    Benches.setupMemory
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.25
    nrOfUpdates: 6
  seeds:    [75,73,70,81,72,68,77,66,75,73,75,77,68,70,78,79,72,74,73,75]

suite.bench
  category: 'incremental'
  series:   '3 updates (25%)'
  setup:    Benches.setupMemory
  setupOpts:
    versioning: 'structured_content_diff'
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.25
    nrOfUpdates: 3
  seeds:    [90,80,83,77,94,97,97,79,87,91,79,102,85,79,81,92,97,90,87,93]

suite.bench
  category: 'merged'
  series:   '3 updates (25%)'
  setup:    Benches.setupMemory
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.25
    nrOfUpdates: 3
  seeds:    [44,46,44,54,53,52,54,53,48,46,49,49,52,50,55,46,50,55,47,49]

# 37% change

suite.bench
  category: 'incremental'
  series:   '15 updates (37%)'
  setup:    Benches.setupMemory
  setupOpts:
    versioning: 'structured_content_diff'
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.375
    nrOfUpdates: 15
  seeds:    [350,374,376,340,364,403,417,381,363,347,354,321,341,388,358,338,361,373,305,350]

suite.bench
  category: 'merged'
  series:   '15 updates (37%)'
  setup:    Benches.setupMemory
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.375
    nrOfUpdates: 15
  seeds:    [94,101,99,97,97,100,100,95,99,95,95,98,96,98,99,97,93,99,95,99]

suite.bench
  category: 'incremental'
  series:   '12 updates (37%)'
  setup:    Benches.setupMemory
  setupOpts:
    versioning: 'structured_content_diff'
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.375
    nrOfUpdates: 12
  seeds:    [350,374,376,340,364,403,417,381,363,347,354,321,341,388,358,338,361,373,305,350]

suite.bench
  category: 'merged'
  series:   '12 updates (37%)'
  setup:    Benches.setupMemory
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.375
    nrOfUpdates: 12
  seeds:    [94,101,99,97,97,100,100,95,99,95,95,98,96,98,99,97,93,99,95,99]

suite.bench
  category: 'incremental'
  series:   '9 updates (37%)'
  setup:    Benches.setupMemory
  setupOpts:
    versioning: 'structured_content_diff'
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.375
    nrOfUpdates: 9
  seeds:    [268,249,254,272,251,261,297,254,266,258,252,263,251,250,281,239,265,274,236,292]

suite.bench
  category: 'merged'
  series:   '9 updates (37%)'
  setup:    Benches.setupMemory
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.375
    nrOfUpdates: 9
  seeds:    [87,89,91,91,94,91,88,93,88,89,87,92,88,85,90,92,87,90,87,89]

suite.bench
  category: 'incremental'
  series:   '6 updates (37%)'
  setup:    Benches.setupMemory
  setupOpts:
    versioning: 'structured_content_diff'
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.375
    nrOfUpdates: 6
  seeds:    [181,177,201,226,191,170,169,162,178,174,146,173,170,169,175,150,174,170,186,169]

suite.bench
  category: 'merged'
  series:   '6 updates (37%)'
  setup:    Benches.setupMemory
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.375
    nrOfUpdates: 6
  seeds:    [75,73,70,81,72,68,77,66,75,73,75,77,68,70,78,79,72,74,73,75]

suite.bench
  category: 'incremental'
  series:   '3 updates (37%)'
  setup:    Benches.setupMemory
  setupOpts:
    versioning: 'structured_content_diff'
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.375
    nrOfUpdates: 3
  seeds:    [90,80,83,77,94,97,97,79,87,91,79,102,85,79,81,92,97,90,87,93]

suite.bench
  category: 'merged'
  series:   '3 updates (37%)'
  setup:    Benches.setupMemory
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.375
    nrOfUpdates: 3
  seeds:    [44,46,44,54,53,52,54,53,48,46,49,49,52,50,55,46,50,55,47,49]
