suite = @memory = new Suite
  name:      'memory'
  container: 'tab2'
  title:     'Incremental vs. Merged Browser Log'
  subtitle:  'Memory footprint for recording local changes'
  baseline:  ->
  record:    ->
    (JSON.stringify(@answer._versioning.patches).length / JSON.stringify(@answer.attributes).length) * 100
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
  seeds:    [176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176,176]

suite.bench
  category: 'merged'
  series:   '12 versions'
  setup:    Benches.  setupContent12
  before:   Benches. beforeContent12
  test:     Benches.       content12
  seeds:    [98,98,98,98,98,98,98,98,98,98,98,98,98,98,98,98,98,98,98,98]

suite.bench
  category: 'incremental'
  series:   '6 versions'
  setup:    Benches.  setupPatch6
  before:   Benches. beforePatch6
  test:     Benches.       patch6
  seeds:    [85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85,85]

suite.bench
  category: 'merged'
  series:   '6 versions'
  setup:    Benches.  setupContent6
  before:   Benches. beforeContent6
  test:     Benches.       content6
  seeds:    [98,98,98,98,98,98,98,98,98,98,98,98,98,98,98,98,98,98,98,98]

suite.bench
  category: 'incremental'
  series:   '3 versions'
  setup:    Benches.  setupPatch3
  before:   Benches. beforePatch3
  test:     Benches.       patch3
  seeds:    [40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40]

suite.bench
  category: 'merged'
  series:   '3 versions'
  setup:    Benches.  setupContent3
  before:   Benches. beforeContent3
  test:     Benches.       content3
  seeds:    [98,98,98,98,98,98,98,98,98,98,98,98,98,98,98,98,98,98,98,98]

