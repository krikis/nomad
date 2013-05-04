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
  seeds:    [154,193,166,179,173,240,157,183,182,184,153,169,162,170,166,162,185,190,199,152]

suite.bench
  category: 'merged'
  series:   '18 updates (12%)'
  setup:    Benches.setupMemory
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.125
    nrOfUpdates: 18
  seeds:    [85,86,86,78,89,87,91,86,87,93,89,85,83,90,92,78,86,84,84,88]

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
  seeds:    [165,183,151,159,164,165,163,153,145,154,132,201,129,148,143,168,169,169,159,189]

suite.bench
  category: 'merged'
  series:   '15 updates (12%)'
  setup:    Benches.setupMemory
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.125
    nrOfUpdates: 15
  seeds:    [75,76,71,83,81,79,87,84,78,73,77,74,73,87,80,85,79,81,75,84]

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
  seeds:    [138,128,142,144,112,107,126,125,141,118,150,114,141,117,138,103,121,137,120,124]

suite.bench
  category: 'merged'
  series:   '12 updates (12%)'
  setup:    Benches.setupMemory
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.125
    nrOfUpdates: 12
  seeds:    [71,69,68,71,76,73,72,69,69,68,73,67,61,74,77,78,79,75,75,73]

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
  seeds:    [93,91,109,94,104,109,108,114,90,126,95,111,90,93,95,87,108,98,99,83]

suite.bench
  category: 'merged'
  series:   '9 updates (12%)'
  setup:    Benches.setupMemory
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.125
    nrOfUpdates: 9
  seeds:    [57,57,59,59,58,61,68,64,68,71,64,60,63,57,62,53,59,57,55,58]

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
  seeds:    [64,58,68,68,61,73,65,71,61,70,65,58,65,70,68,65,59,58,50,69]

suite.bench
  category: 'merged'
  series:   '6 updates (12%)'
  setup:    Benches.setupMemory
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.125
    nrOfUpdates: 6
  seeds:    [47,56,45,40,43,42,47,51,45,43,32,34,41,37,48,52,45,39,43,45]

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
  seeds:    [37,35,36,29,35,34,32,25,28,26,31,26,25,26,27,34,33,28,29,33]

suite.bench
  category: 'merged'
  series:   '3 updates (12%)'
  setup:    Benches.setupMemory
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.125
    nrOfUpdates: 3
  seeds:    [24,31,30,26,29,26,23,28,29,30,28,20,28,31,30,26,21,21,20,21]

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
  seeds:    [516,571,472,643,524,525,521,558,634,474,612,603,543,490,489,455,525,545,574,524]

suite.bench
  category: 'merged'
  series:   '18 updates (25%)'
  setup:    Benches.setupMemory
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.25
    nrOfUpdates: 18
  seeds:    [105,104,104,106,100,108,101,103,103,105,102,102,101,103,107,105,105,106,105,103]

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
  seeds:    [459,464,469,507,410,414,499,465,408,493,420,526,496,473,442,419,449,420,496,449]

suite.bench
  category: 'merged'
  series:   '15 updates (25%)'
  setup:    Benches.setupMemory
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.25
    nrOfUpdates: 15
  seeds:    [100,99,100,105,104,100,102,100,103,101,105,97,100,101,101,106,100,105,103,99]

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
  seeds:    [328,394,384,343,377,396,335,335,329,350,369,377,453,335,320,374,321,326,339,387]

suite.bench
  category: 'merged'
  series:   '12 updates (25%)'
  setup:    Benches.setupMemory
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.25
    nrOfUpdates: 12
  seeds:    [94,96,94,101,99,100,96,91,95,99,97,93,103,100,93,96,98,93,92,96]

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
  seeds:    [276,283,297,239,265,253,294,278,288,273,242,244,296,260,263,260,248,251,231,275]

suite.bench
  category: 'merged'
  series:   '9 updates (25%)'
  setup:    Benches.setupMemory
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.25
    nrOfUpdates: 9
  seeds:    [85,90,90,90,87,83,94,92,90,82,89,90,92,93,90,84,87,92,89,90]

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
  seeds:    [189,162,166,173,203,175,176,156,182,174,187,178,197,183,164,177,168,172,161,191]

suite.bench
  category: 'merged'
  series:   '6 updates (25%)'
  setup:    Benches.setupMemory
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.25
    nrOfUpdates: 6
  seeds:    [72,67,75,77,74,68,73,74,79,79,77,69,82,75,68,80,64,80,71,72]

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
  seeds:    [74,80,92,91,75,77,94,102,91,93,103,94,88,89,88,91,86,97,84,103]

suite.bench
  category: 'merged'
  series:   '3 updates (25%)'
  setup:    Benches.setupMemory
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.25
    nrOfUpdates: 3
  seeds:    [46,44,45,50,55,41,43,52,47,46,43,43,46,48,50,41,54,50,51,55]

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
  seeds:    [907,981,912,1003,930,955,1067,865,945,892,934,1131,818,986,962,901,1059,1016,941,1201]

suite.bench
  category: 'merged'
  series:   '18 updates (37%)'
  setup:    Benches.setupMemory
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.375
    nrOfUpdates: 18
  seeds:    [111,107,111,107,107,109,109,110,106,109,109,108,109,109,109,109,108,108,110,110]

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
  seeds:    [749,855,840,799,787,739,802,741,862,684,796,853,763,865,698,939,923,889,771,866]

suite.bench
  category: 'merged'
  series:   '15 updates (37%)'
  setup:    Benches.setupMemory
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.375
    nrOfUpdates: 15
  seeds:    [108,106,106,104,105,107,106,106,108,107,107,108,102,106,107,108,107,107,107,106]

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
  seeds:    [664,693,643,694,765,629,640,667,607,671,564,635,620,587,599,588,598,604,655,565]

suite.bench
  category: 'merged'
  series:   '12 updates (37%)'
  setup:    Benches.setupMemory
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.375
    nrOfUpdates: 12
  seeds:    [106,108,104,105,102,104,103,104,105,106,104,104,104,104,99,103,104,104,104,104]

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
  seeds:    [485,459,486,457,443,404,532,480,464,466,408,502,401,415,478,451,479,438,428,472]

suite.bench
  category: 'merged'
  series:   '9 updates (37%)'
  setup:    Benches.setupMemory
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.375
    nrOfUpdates: 9
  seeds:    [103,98,102,98,102,97,99,100,99,95,101,100,98,95,102,96,97,102,96,101]

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
  seeds:    [336,305,310,293,294,284,308,309,309,278,316,292,327,329,277,335,297,334,295,289]

suite.bench
  category: 'merged'
  series:   '6 updates (37%)'
  setup:    Benches.setupMemory
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.375
    nrOfUpdates: 6
  seeds:    [79,86,93,87,84,83,91,81,87,89,88,94,93,89,89,93,85,91,85,92]

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
  seeds:    [141,151,152,161,180,152,122,162,147,157,149,141,143,144,143,138,133,155,135,159]

suite.bench
  category: 'merged'
  series:   '3 updates (37%)'
  setup:    Benches.setupMemory
  before:   Benches.beforeMemory
  test:     Benches.memory
  testOpts:
    changeRate: 0.375
    nrOfUpdates: 3
  seeds:    [55,61,60,60,63,64,63,60,69,67,52,68,61,58,71,62,61,52,63,72]
