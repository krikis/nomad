suite = @resolution = new Suite
  name:      'resolution'
  container: 'tab4'
  title:     'Serialized Data vs. Attribute Oriented Approach'
  subtitle:  'Proportion successfully resolved conflicts'
  yMax:      100
  baseline:  ->
  record:    ->
    @count += 1
    @success * 100
  unit:      '%'
  unitLong:  'Successfully resolved'
  # benchRuns: 1
  # maxRuns:   1

suite.bench
  category: 'serialized'
  series:   '37% change'
  setup:    Benches.  setupSerialized37
  before:   Benches. beforeSerialized37
  test:     Benches.       serialized37
  seeds:    [40,20,40,10,50,20,10,50,20,10,30,20,0,10,20,10,30,0,10,10,40,20,50,30,20,20,30,40,10,10,20,30,10,20,40,40,10,30,20,10,40,30,10,30,40,30,20,10,30]

suite.bench
  category: 'serialized'
  series:   '25% change'
  setup:    Benches.  setupSerialized25
  before:   Benches. beforeSerialized25
  test:     Benches.       serialized25
  seeds:    [40,40,60,50,30,70,70,50,60,40,60,80,70,40,40,50,30,30,80,50,40,40,0,50,40,70,30,50,60,50,40,30,70,60,40,40,50,50,40,80,70,40,70,60,60,50,40,50,50]

suite.bench
  category: 'serialized'
  series:   '12% change'
  setup:    Benches.  setupSerialized12
  before:   Benches. beforeSerialized12
  test:     Benches.       serialized12
  seeds:    [100,90,90,70,60,100,90,80,90,100,100,90,90,80,90,100,90,100,100,90,70,80,90,90,60,90,90,90,80,70,90,80,80,80,90,80,90,100,70,90,90,90,80,90,80,100,100,90,90]

suite.bench
  category: 'serialized'
  series:   '37% (only strings)'
  setup:    Benches.  setupSerialized37String
  before:   Benches. beforeSerialized37String
  test:     Benches.       serialized37String
  seeds:    [10,10,30,10,20,10,10,40,20,20,20,0,20,10,10,30,20,20,0,10,0,30,20,20,30,40,20,30,20,0,0,0,30,0,30,10,50,10,10,20,10,0,0,30,20,10,40,0,20]

suite.bench
  category: 'serialized'
  series:   '25% (only strings)'
  setup:    Benches.  setupSerialized25String
  before:   Benches. beforeSerialized25String
  test:     Benches.       serialized25String
  seeds:    [30,30,30,40,40,40,30,40,50,30,60,40,30,40,60,40,40,60,60,30,30,60,60,40,20,50,20,50,40,50,30,20,50,30,60,40,60,20,70,40,40,70,40,10,30,30,20,50,60]

suite.bench
  category: 'serialized'
  series:   '12% (only strings)'
  setup:    Benches.  setupSerialized12String
  before:   Benches. beforeSerialized12String
  test:     Benches.       serialized12String
  seeds:    [100,80,90,100,90,80,90,90,90,70,90,100,100,60,90,100,90,90,100,90,100,90,100,80,90,80,100,90,70,80,90,80,70,80,90,80,100,80,100,100,90,100,100,70,90,80,90,80,100]

suite.bench
  category: 'serialized'
  series:   '37% (no additions/deletions)'
  setup:    Benches.  setupSerialized37Change
  before:   Benches. beforeSerialized37Change
  test:     Benches.       serialized37Change
  seeds:    [30,40,30,30,60,40,30,40,50,60,30,40,40,30,20,30,0,40,30,30,40,0,10,40,0,40,20,30,60,30,10,40,20,20,40,40,40,0,40,10,30,30,0,20,10,40,70,30,40]

suite.bench
  category: 'serialized'
  series:   '25% (no additions/deletions)'
  setup:    Benches.  setupSerialized25Change
  before:   Benches. beforeSerialized25Change
  test:     Benches.       serialized25Change
  seeds:    [80,60,70,80,70,80,80,50,70,90,90,90,80,70,60,80,60,60,90,50,100,60,80,80,100,70,40,90,60,100,80,50,70,100,80,60,80,70,90,80,60,60,80,70,90,80,90,90,90]

suite.bench
  category: 'serialized'
  series:   '12% (no additions/deletions)'
  setup:    Benches.  setupSerialized12Change
  before:   Benches. beforeSerialized12Change
  test:     Benches.       serialized12Change
  seeds:    [100,90,100,90,100,100,100,90,100,100,80,100,90,100,80,100,90,90,100,100,100,100,100,100,100,100,100,100,100,90,100,100,90,80,90,100,90,90,100,100,90,100,100,90,100,100,100,90,100]

suite.bench
  category: 'attributes'
  series:   '37% change'
  setup:    Benches.  setupAttribute37
  before:   Benches. beforeAttribute37
  test:     Benches.       attribute37
  seeds:    [90,50,40,60,50,80,80,70,100,90,80,50,90,60,60,70,60,90,80,70,80,70,100,80,60,80,70,60,90,70,50,70,60,80,60,70,80,80,60,100,100,60,70,40,70,70,100,80,70]

suite.bench
  category: 'attributes'
  series:   '25% change'
  setup:    Benches.  setupAttribute25
  before:   Benches. beforeAttribute25
  test:     Benches.       attribute25
  seeds:    [100,80,90,100,100,90,90,80,100,90,100,100,90,100,100,90,90,90,100,90,100,100,100,90,100,100,90,90,100,100,70,80,100,100,100,90,100,100,100,100,90,90,100,100,90,90,100,100,100]

suite.bench
  category: 'attributes'
  series:   '12% change'
  setup:    Benches.  setupAttribute12
  before:   Benches. beforeAttribute12
  test:     Benches.       attribute12
  seeds:    [100,90,90,100,100,100,100,100,100,100,100,100,90,100,100,90,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,90,90,100,100,100,90,100,90,100,100,100,100,100,100]

suite.bench
  category: 'attributes'
  series:   '37% (only strings)'
  setup:    Benches.  setupAttribute37String
  before:   Benches. beforeAttribute37String
  test:     Benches.       attribute37String
  seeds:    [40,60,90,40,80,40,60,70,70,70,60,60,50,40,50,80,50,40,70,70,40,40,70,80,80,50,60,90,70,90,60,100,80,80,70,70,60,100,60,80,70,90,60,70,80,70,70,70,70]

suite.bench
  category: 'attributes'
  series:   '25% (only strings)'
  setup:    Benches.  setupAttribute25String
  before:   Benches. beforeAttribute25String
  test:     Benches.       attribute25String
  seeds:    [90,80,90,100,100,80,100,100,90,60,90,80,90,100,90,70,90,100,80,80,100,80,100,90,100,90,80,100,90,100,90,100,90,80,90,90,100,100,90,90,80,100,80,60,80,90,80,90,90]

suite.bench
  category: 'attributes'
  series:   '12% (only strings)'
  setup:    Benches.  setupAttribute12String
  before:   Benches. beforeAttribute12String
  test:     Benches.       attribute12String
  seeds:    [100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,90,100,90,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,90,100,100,100,100,100,100,100,100,100,100,90,100,100]

suite.bench
  category: 'attributes'
  series:   '37% (no additions/deletions)'
  setup:    Benches.  setupAttribute37Change
  before:   Benches. beforeAttribute37Change
  test:     Benches.       attribute37Change
  seeds:    [40,40,50,40,50,30,30,20,30,40,20,80,30,20,50,30,40,20,40,40,20,30,30,60,30,60,30,40,40,40,40,50,50,40,30,50,40,20,60,50,30,60,50,40,40,30,50,50,40]

suite.bench
  category: 'attributes'
  series:   '25% (no additions/deletions)'
  setup:    Benches.  setupAttribute25Change
  before:   Benches. beforeAttribute25Change
  test:     Benches.       attribute25Change
  seeds:    [90,80,80,90,70,90,50,90,80,80,80,60,80,80,50,80,90,70,70,60,70,90,80,90,80,90,60,80,80,90,70,70,60,80,80,80,60,60,90,60,90,80,90,90,80,80,60,90,90]

suite.bench
  category: 'attributes'
  series:   '12% (no additions/deletions)'
  setup:    Benches.  setupAttribute12Change
  before:   Benches. beforeAttribute12Change
  test:     Benches.       attribute12Change
  seeds:    [100,100,100,100,100,100,90,90,100,100,100,90,100,100,100,100,100,100,100,100,100,100,100,90,100,100,100,100,90,90,90,100,90,90,100,90,100,100,90,100,90,100,100,90,100,100,100,100,100]

