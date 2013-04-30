suite = @resolution = new Suite
  name:      'resolution'
  container: 'tab4'
  title:     'Serialized Data vs. Attribute Oriented Approach'
  subtitle:  'Proportion successfully resolved conflicts'
  yMax:      100
  baseline:  ->
  record:    ->
    @count += 1
    if @success then 100 else 0
  unit:      '%'
  unitLong:  'Successfully resolved'
  # benchRuns: 1
  # maxRuns:   1

suite.bench
  category: 'serialized'
  series:   '37%'
  setup:    Benches.setupResolution
  setupOpts:
    versioning: 'structured_content_diff'
  before:   Benches.beforeResolution
  beforeOpts:
    changeRate: 0.375
  test:     Benches.resolution
  seeds:    [10,20,10,0,0,0,10,0,10,20,10,30,20,0,20,10,10,20,0,20,10,10,0,0,20,10,30,30,0,20,10,10,0,10,10,0,20,10,20,20,10,20,20,0,0,0,10,10,10,10]

suite.bench
  category: 'serialized'
  series:   '25%'
  setup:    Benches.setupResolution
  setupOpts:
    versioning: 'structured_content_diff'
  before:   Benches.beforeResolution
  beforeOpts:
    changeRate: 0.25
  test:     Benches.resolution
  seeds:    [20,20,30,40,30,20,30,30,20,20,20,0,40,40,40,30,60,30,20,30,0,40,50,10,10,20,50,30,20,30,10,40,50,30,30,20,40,50,10,10,10,20,30,20,20,20,10,30,40,60]

suite.bench
  category: 'serialized'
  series:   '12%'
  setup:    Benches.setupResolution
  setupOpts:
    versioning: 'structured_content_diff'
  before:   Benches.beforeResolution
  beforeOpts:
    changeRate: 0.125
  test:     Benches.resolution
  seeds:    [70,80,90,70,70,70,90,80,70,70,40,80,70,90,60,90,70,60,100,80,70,70,90,70,70,90,60,40,80,80,70,70,70,80,70,60,80,70,80,70,80,80,60,80,80,90,90,80,60,70]

suite.bench
  category: 'serialized'
  series:   '37% (invalid data)'
  setup:    Benches.setupResolution
  setupOpts:
    versioning: 'structured_content_diff'
  before:   Benches.beforeResolution
  beforeOpts:
    changeRate: 0.375
  test:     Benches.resolution
  round: false
  record:   ->
    unless @success
      @count += 1
      if @invalid then 100 else 0
    else
      0
  seeds:    [10,0,0,0,0,0,0,0,0,0,0,0,0,0,0,10,0,0,10,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,10,0,0,0,0,0,0,0,0,0,0,0]

suite.bench
  category: 'serialized'
  series:   '25% (invalid data)'
  setup:    Benches.setupResolution
  setupOpts:
    versioning: 'structured_content_diff'
  before:   Benches.beforeResolution
  beforeOpts:
    changeRate: 0.25
  test:     Benches.resolution
  round: false
  record:   ->
    unless @success
      @count += 1
      if @invalid then 100 else 0
    else
      0
  seeds:    [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,10,10,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

suite.bench
  category: 'serialized'
  series:   '12% (invalid data)'
  setup:    Benches.setupResolution
  setupOpts:
    versioning: 'structured_content_diff'
  before:   Benches.beforeResolution
  beforeOpts:
    changeRate: 0.125
  test:     Benches.resolution
  round: false
  record:   ->
    unless @success
      @count += 1
      if @invalid then 100 else 0
    else
      0
  seeds:    [0,0,0,0,10,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,10,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,10,0,0,0,0,0,0,0,0,0,0,0]

suite.bench
  category: 'serialized'
  series:   '37% (strings only)'
  setup:    Benches.setupResolution
  setupOpts:
    versioning: 'structured_content_diff'
  before:   Benches.beforeResolution
  beforeOpts:
    changeRate: 0.375
    typeOdds: [0, 0, 1, 2]
  test:     Benches.resolution
  seeds:    [0,0,10,0,10,0,20,10,20,0,0,10,10,10,0,30,20,40,10,20,30,0,0,10,20,10,40,20,10,0,50,10,0,0,0,0,0,10,0,10,10,0,10,10,20,30,10,60,0,10]

suite.bench
  category: 'serialized'
  series:   '25% (strings only)'
  setup:    Benches.setupResolution
  setupOpts:
    versioning: 'structured_content_diff'
  before:   Benches.beforeResolution
  beforeOpts:
    changeRate: 0.25
    typeOdds: [0, 0, 1, 2]
  test:     Benches.resolution
  seeds:    [50,50,80,10,10,20,30,40,30,40,30,30,30,50,30,30,40,30,30,20,20,20,50,30,40,50,10,20,20,40,20,10,10,30,50,20,20,40,10,30,40,30,20,10,30,30,30,30,60,40]

suite.bench
  category: 'serialized'
  series:   '12% (strings only)'
  setup:    Benches.setupResolution
  setupOpts:
    versioning: 'structured_content_diff'
  before:   Benches.beforeResolution
  beforeOpts:
    changeRate: 0.125
    typeOdds: [0, 0, 1, 2]
  test:     Benches.resolution
  seeds:    [80,80,80,90,60,60,90,80,80,80,70,60,60,90,70,50,60,70,70,80,60,30,70,80,90,70,90,40,70,50,50,70,50,60,70,60,80,60,70,80,80,70,90,60,60,70,50,70,70,80]

suite.bench
  category: 'serialized'
  series:   '37% (mods only)'
  setup:    Benches.setupResolution
  setupOpts:
    versioning: 'structured_content_diff'
  before:   Benches.beforeResolution
  beforeOpts:
    changeRate: 0.375
    changeOdds: [0, 1, 0]
  test:     Benches.resolution
  seeds:    [60,30,60,30,20,40,30,30,50,30,30,20,40,20,20,50,20,20,40,40,30,20,10,30,50,50,10,50,20,20,40,30,30,30,20,30,30,60,30,30,40,30,30,10,30,40,20,20,20,0]

suite.bench
  category: 'serialized'
  series:   '25% (mods only)'
  setup:    Benches.setupResolution
  setupOpts:
    versioning: 'structured_content_diff'
  before:   Benches.beforeResolution
  beforeOpts:
    changeRate: 0.25
    changeOdds: [0, 1, 0]
  test:     Benches.resolution
  seeds:    [60,30,90,60,70,70,80,80,80,80,50,60,60,80,70,50,50,90,70,70,80,60,40,70,70,80,80,90,90,50,70,70,80,60,50,70,70,60,60,70,40,90,90,90,70,70,80,70,70,80]

suite.bench
  category: 'serialized'
  series:   '12% (mods only)'
  setup:    Benches.setupResolution
  setupOpts:
    versioning: 'structured_content_diff'
  before:   Benches.beforeResolution
  beforeOpts:
    changeRate: 0.125
    changeOdds: [0, 1, 0]
  test:     Benches.resolution
  seeds:    [90,80,100,100,100,100,90,100,100,90,90,100,90,100,100,100,100,80,80,100,90,100,100,100,80,90,100,100,100,90,100,90,90,90,70,100,90,90,100,100,100,90,100,90,100,100,100,100,100,90]

suite.bench
  category: 'attributes'
  series:   '37%'
  setup:    Benches.setupResolution
  before:   Benches.beforeResolution
  beforeOpts:
    changeRate: 0.375
  test:     Benches.resolution
  seeds:    [90,80,80,80,70,80,80,70,70,70,90,90,100,90,80,70,50,80,70,90,60,80,50,80,60,70,90,70,90,70,80,90,80,80,70,80,60,70,90,80,70,70,60,80,70,70,80,60,90,60]

suite.bench
  category: 'attributes'
  series:   '25%'
  setup:    Benches.setupResolution
  before:   Benches.beforeResolution
  beforeOpts:
    changeRate: 0.25
  test:     Benches.resolution
  seeds:    [90,90,100,100,100,100,100,100,90,100,100,100,80,90,90,80,100,80,100,90,70,90,100,70,100,100,90,80,90,70,80,80,100,90,80,90,100,100,80,100,90,90,80,100,100,100,70,60,100,80]

suite.bench
  category: 'attributes'
  series:   '12%'
  setup:    Benches.setupResolution
  before:   Benches.beforeResolution
  beforeOpts:
    changeRate: 0.125
  test:     Benches.resolution
  seeds:    [100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,90,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,80,100,100,100,100,100,90,90,100,100,100,100]

suite.bench
  category: 'attributes'
  series:   '37% (strings only)'
  setup:    Benches.setupResolution
  before:   Benches.beforeResolution
  beforeOpts:
    changeRate: 0.375
    typeOdds: [0, 0, 1, 2]
  test:     Benches.resolution
  seeds:    [50,50,70,90,80,80,80,70,50,100,70,60,50,90,80,80,60,80,90,50,90,80,70,70,50,80,60,80,70,80,70,80,70,30,70,70,50,60,60,50,70,100,70,80,80,70,80,50,60,70]

suite.bench
  category: 'attributes'
  series:   '25% (strings only)'
  setup:    Benches.setupResolution
  before:   Benches.beforeResolution
  beforeOpts:
    changeRate: 0.25
    typeOdds: [0, 0, 1, 2]
  test:     Benches.resolution
  seeds:    [90,80,100,80,100,90,60,100,90,90,80,90,80,90,80,90,100,100,100,80,80,80,100,90,100,90,100,90,80,90,100,80,100,80,80,80,100,80,80,100,90,100,80,90,100,90,70,90,80,90]

suite.bench
  category: 'attributes'
  series:   '12% (strings only)'
  setup:    Benches.setupResolution
  before:   Benches.beforeResolution
  beforeOpts:
    changeRate: 0.125
    typeOdds: [0, 0, 1, 2]
  test:     Benches.resolution
  seeds:    [100,100,100,100,100,100,100,90,100,100,100,100,100,100,90,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,90,100,100,100,100,100,100,100,100,100,100]

suite.bench
  category: 'attributes'
  series:   '37% (mods only)'
  setup:    Benches.setupResolution
  before:   Benches.beforeResolution
  beforeOpts:
    changeRate: 0.375
    changeOdds: [0, 1, 0]
  test:     Benches.resolution
  seeds:    [60,40,60,30,60,20,60,50,40,60,60,30,50,60,90,60,30,40,30,20,50,20,30,70,50,30,20,50,40,50,20,30,30,30,20,30,70,20,30,30,40,40,40,60,50,40,30,40,40,40]

suite.bench
  category: 'attributes'
  series:   '25% (mods only)'
  setup:    Benches.setupResolution
  before:   Benches.beforeResolution
  beforeOpts:
    changeRate: 0.25
    changeOdds: [0, 1, 0]
  test:     Benches.resolution
  seeds:    [100,70,80,50,70,100,70,60,70,70,90,60,70,70,90,90,70,80,70,90,80,80,90,80,90,70,70,80,90,70,70,80,90,70,70,80,90,90,90,60,70,80,70,100,50,70,80,60,50,90]

suite.bench
  category: 'attributes'
  series:   '12% (mods only)'
  setup:    Benches.setupResolution
  before:   Benches.beforeResolution
  beforeOpts:
    changeRate: 0.125
    changeOdds: [0, 1, 0]
  test:     Benches.resolution
  seeds:    [90,100,100,90,100,100,90,90,100,90,100,90,100,100,100,100,100,90,100,100,100,100,100,90,100,100,90,100,90,100,100,100,90,100,100,100,100,100,100,100,100,90,90,100,100,100,100,100,100,90]

