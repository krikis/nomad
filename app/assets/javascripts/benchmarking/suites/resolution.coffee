suite = @resolution = new Suite
  name:      'resolution'
  container: 'tab4'
  title:     'Patching Serialized Objects vs. Rebasing Individual Attributes'
  subtitle:  'Outcome of the reconciliation process'
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
  seeds:    [0,0,0,0,0,0,0,0,0,0,10,0,0,0,0,10,0,0,0,0,0,0,0,0]

suite.bench
  category: 'serialized'
  series:   '25% change'
  setup:    Benches.  setupSerialized25
  before:   Benches. beforeSerialized25
  test:     Benches.       serialized25
  seeds:    [40,30,40,30,30,40,30,20,50,30,20,30,10,30,40,20,30,30,10,30,20,20,20,30]

suite.bench
  category: 'serialized'
  series:   '12% change'
  setup:    Benches.  setupSerialized12
  before:   Benches. beforeSerialized12
  test:     Benches.       serialized12
  seeds:    [70,80,40,80,40,70,80,60,70,80,70,60,30,70,70,70,90,70,100,80,90,70,60,60]

suite.bench
  category: 'attributes'
  series:   '37% change'
  setup:    Benches.  setupAttribute37
  before:   Benches. beforeAttribute37
  test:     Benches.       attribute37
  seeds:    [30,50,40,60,60,40,60,60,50,50,60,80,30,50,50,70,50,50,60,30,30,80,50,50]

suite.bench
  category: 'attributes'
  series:   '25% change'
  setup:    Benches.  setupAttribute25
  before:   Benches. beforeAttribute25
  test:     Benches.       attribute25
  seeds:    [90,100,100,90,80,100,90,90,90,80,80,70,90,90,100,90,90,80,80,90,90,90,80,100]

suite.bench
  category: 'attributes'
  series:   '12% change'
  setup:    Benches.  setupAttribute12
  before:   Benches. beforeAttribute12
  test:     Benches.       attribute12
  seeds:    [100,100,100,100,100,100,90,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100]


