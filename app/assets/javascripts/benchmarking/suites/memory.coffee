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
  seeds:    [253,232,199,224,274,270,264,242,316,293,257,236,259,350,269,300,338,296,283,315]

suite.bench
  category: 'merged'
  series:   '12 versions'
  setup:    Benches.  setupContent12
  before:   Benches. beforeContent12
  test:     Benches.       content12
  seeds:    [98,101,99,97,98,99,99,97,99,99,100,97,99,97,101,97,100,95,98,98]

suite.bench
  category: 'incremental'
  series:   '9 versions'
  setup:    Benches.  setupPatch9
  before:   Benches. beforePatch9
  test:     Benches.       patch9
  seeds:    []

suite.bench
  category: 'merged'
  series:   '9 versions'
  setup:    Benches.  setupContent9
  before:   Benches. beforeContent9
  test:     Benches.       content9
  seeds:    []

suite.bench
  category: 'incremental'
  series:   '6 versions'
  setup:    Benches.  setupPatch6
  before:   Benches. beforePatch6
  test:     Benches.       patch6
  seeds:    [165,124,116,164,125,128,125,121,137,139,141,127,157,166,124,134,124,155,143,129]

suite.bench
  category: 'merged'
  series:   '6 versions'
  setup:    Benches.  setupContent6
  before:   Benches. beforeContent6
  test:     Benches.       content6
  seeds:    [80,89,85,87,87,90,77,81,82,79,87,84,86,84,93,79,82,83,90,78]

suite.bench
  category: 'incremental'
  series:   '3 versions'
  setup:    Benches.  setupPatch3
  before:   Benches. beforePatch3
  test:     Benches.       patch3
  seeds:    [67,68,78,57,57,67,56,90,72,60,84,66,53,73,90,67,66,63,82,80]

suite.bench
  category: 'merged'
  series:   '3 versions'
  setup:    Benches.  setupContent3
  before:   Benches. beforeContent3
  test:     Benches.       content3
  seeds:    [65,51,50,54,56,62,66,66,65,50,62,64,49,59,62,53,70,71,54,74]

