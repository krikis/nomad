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
  series:   '18 updates (12%)'
  setup:    Benches.setupMemory
  setupOpts:
    versioning: 'structured_content_diff'
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.125
    nrOfUpdates: 18
  seeds:    []

suite.bench
  category: 'merged'
  series:   '18 updates (12%)'
  setup:    Benches.setupMemory
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.125
    nrOfUpdates: 18
  seeds:    []

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
  seeds:    [163,137,137,148,157,149,167,172,184,158,133,201,158,156,169,209,136,171,146,164]

suite.bench
  category: 'merged'
  series:   '15 updates (12%)'
  setup:    Benches.setupMemory
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.125
    nrOfUpdates: 15
  seeds:    [77,82,78,79,74,71,81,80,79,82,83,73,85,83,82,76,82,83,79,79]

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
  seeds:    [130,127,127,120,96,139,113,117,150,108,108,126,121,151,142,110,138,107,135,124]

suite.bench
  category: 'merged'
  series:   '12 updates (12%)'
  setup:    Benches.setupMemory
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.125
    nrOfUpdates: 12
  seeds:    [76,74,75,77,72,78,67,74,63,66,63,74,70,73,75,70,73,71,76,69]

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
  seeds:    [107,97,87,101,108,107,87,104,103,85,99,71,72,85,102,94,86,108,92,98]

suite.bench
  category: 'merged'
  series:   '9 updates (12%)'
  setup:    Benches.setupMemory
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.125
    nrOfUpdates: 9
  seeds:    [58,62,60,63,65,61,66,64,59,63,55,63,70,59,69,57,60,60,59,67]

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
  seeds:    [66,77,56,67,65,68,67,60,61,58,56,54,69,72,58,63,67,50,65,69]

suite.bench
  category: 'merged'
  series:   '6 updates (12%)'
  setup:    Benches.setupMemory
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.125
    nrOfUpdates: 6
  seeds:    [46,45,39,49,41,47,44,50,42,45,44,43,46,47,42,44,42,45,52,40]

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
  seeds:    [37,35,25,33,26,28,20,30,31,31,36,26,43,29,29,33,25,30,34,27]

suite.bench
  category: 'merged'
  series:   '3 updates (12%)'
  setup:    Benches.setupMemory
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.125
    nrOfUpdates: 3
  seeds:    [27,29,26,24,22,33,30,32,25,24,27,23,26,37,27,22,31,32,26,37]

# 25% change

suite.bench
  category: 'incremental'
  series:   '18 updates (25%)'
  setup:    Benches.setupMemory
  setupOpts:
    versioning: 'structured_content_diff'
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.25
    nrOfUpdates: 18
  seeds:    []

suite.bench
  category: 'merged'
  series:   '18 updates (25%)'
  setup:    Benches.setupMemory
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.25
    nrOfUpdates: 18
  seeds:    []

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
  seeds:    [502,507,486,458,439,481,455,418,397,425,417,439,478,420,529,478,452,424,478,406]

suite.bench
  category: 'merged'
  series:   '15 updates (25%)'
  setup:    Benches.setupMemory
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.25
    nrOfUpdates: 15
  seeds:    [101,98,105,101,103,103,103,101,97,101,104,103,105,101,98,102,101,101,99,104]

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
  seeds:    [332,340,330,382,344,376,349,406,324,334,342,339,323,335,352,353,358,373,361,332]

suite.bench
  category: 'merged'
  series:   '12 updates (25%)'
  setup:    Benches.setupMemory
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.25
    nrOfUpdates: 12
  seeds:    [98,93,92,98,97,92,98,98,93,99,99,97,97,96,99,101,96,99,100,96]

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
  seeds:    [296,320,299,284,256,284,255,252,252,256,273,274,283,270,274,264,257,294,255,243]

suite.bench
  category: 'merged'
  series:   '9 updates (25%)'
  setup:    Benches.setupMemory
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.25
    nrOfUpdates: 9
  seeds:    [89,88,85,87,91,80,83,90,81,90,95,85,89,86,89,83,85,97,88,92]

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
  seeds:    [181,194,196,186,179,165,174,207,186,172,173,169,152,166,188,167,185,180,190,183]

suite.bench
  category: 'merged'
  series:   '6 updates (25%)'
  setup:    Benches.setupMemory
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.25
    nrOfUpdates: 6
  seeds:    [75,73,79,82,78,72,74,80,68,72,70,76,73,72,75,68,71,70,80,78]

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
  seeds:    [90,98,77,90,99,88,79,87,85,77,93,87,78,82,89,92,84,85,97,83]

suite.bench
  category: 'merged'
  series:   '3 updates (25%)'
  setup:    Benches.setupMemory
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.25
    nrOfUpdates: 3
  seeds:    [54,53,48,48,51,50,46,49,47,53,39,47,48,45,54,45,36,47,40,52]

# 37% change

suite.bench
  category: 'incremental'
  series:   '18 updates (37%)'
  setup:    Benches.setupMemory
  setupOpts:
    versioning: 'structured_content_diff'
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.375
    nrOfUpdates: 18
  seeds:    []

suite.bench
  category: 'merged'
  series:   '18 updates (37%)'
  setup:    Benches.setupMemory
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.375
    nrOfUpdates: 18
  seeds:    []

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
  seeds:    [782,702,816,780,704,781,739,928,786,861,970,702,776,824,724,847,833,651,771,760]

suite.bench
  category: 'merged'
  series:   '15 updates (37%)'
  setup:    Benches.setupMemory
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.375
    nrOfUpdates: 15
  seeds:    [105,105,109,106,108,106,106,111,110,104,106,108,108,108,107,108,106,106,105,108]

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
  seeds:    [721,623,517,633,639,668,698,594,635,625,593,706,623,661,663,600,623,639,656,725]

suite.bench
  category: 'merged'
  series:   '12 updates (37%)'
  setup:    Benches.setupMemory
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.375
    nrOfUpdates: 12
  seeds:    [104,108,106,103,105,103,106,102,106,105,103,104,105,106,105,104,105,103,102,103]

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
  seeds:    [499,484,446,441,493,498,424,449,480,438,491,450,495,511,455,477,439,467,465,421]

suite.bench
  category: 'merged'
  series:   '9 updates (37%)'
  setup:    Benches.setupMemory
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.375
    nrOfUpdates: 9
  seeds:    [95,103,100,97,103,104,101,101,99,100,100,102,104,101,103,100,100,97,98,102]

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
  seeds:    [285,318,282,308,274,288,312,262,303,316,342,282,314,277,278,277,290,300,307,269]

suite.bench
  category: 'merged'
  series:   '6 updates (37%)'
  setup:    Benches.setupMemory
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.375
    nrOfUpdates: 6
  seeds:    [94,94,90,86,90,92,84,91,88,89,89,86,88,89,88,92,89,83,93,90]

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
  seeds:    [146,177,140,155,146,156,156,151,145,167,157,145,160,131,144,151,145,138,166,128]

suite.bench
  category: 'merged'
  series:   '3 updates (37%)'
  setup:    Benches.setupMemory
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.375
    nrOfUpdates: 3
  seeds:    [64,66,55,66,63,63,67,63,56,61,65,65,61,66,60,59,61,56,66,64]
