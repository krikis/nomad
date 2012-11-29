suite = @memory = new Suite
  name:      'memory'
  container: 'tab2'
  title:     'Incremental vs. Merged Browser Log'
  subtitle:  'Memory footprint for recording local changes'
  baseline:  ->
  record:    ->
    @count += 1
    (JSON.stringify(@answer._versioning.patches).length / JSON.stringify(@answerOriginal).length) * 100
  unit:      '%'
  unitLong:  'Portion of original data'
  # benchRuns: 1
  # maxRuns:   1

suite.bench
  category: 'incremental'
  series:   '12 versions'
  setup:    Benches.  setupPatch12
  before:   Benches. beforePatch12
  test:     Benches.       patch12
  seeds:    [150,122,120,125,135,150,149,119,138,131,124,141,129,118,124,156,119,104,120,127]

suite.bench
  category: 'merged'
  series:   '12 versions'
  setup:    Benches.  setupContent12
  before:   Benches. beforeContent12
  test:     Benches.       content12
  seeds:    [30,24,25,30,31,31,34,35,32,29,36,26,27,23,38,37,27,23,28,33]

suite.bench
  category: 'incremental'
  series:   '6 versions'
  setup:    Benches.  setupPatch6
  before:   Benches. beforePatch6
  test:     Benches.       patch6
  seeds:    [77,83,87,76,95,80,91,90,97,80,91,80,64,86,84,102,96,87,85,81]

suite.bench
  category: 'merged'
  series:   '6 versions'
  setup:    Benches.  setupContent6
  before:   Benches. beforeContent6
  test:     Benches.       content6
  seeds:    [33,23,33,27,42,26,30,32,35,32,34,34,29,26,30,35,25,25,34,22]

suite.bench
  category: 'incremental'
  series:   '3 versions'
  setup:    Benches.  setupPatch3
  before:   Benches. beforePatch3
  test:     Benches.       patch3
  seeds:    [69,49,52,45,78,49,87,67,47,51,57,60,65,53,52,57,47,59,51,52]

suite.bench
  category: 'merged'
  series:   '3 versions'
  setup:    Benches.  setupContent3
  before:   Benches. beforeContent3
  test:     Benches.       content3
  seeds:    [17,16,22,24,23,18,28,21,25,14,29,27,28,29,22,21,30,32,40,17]

