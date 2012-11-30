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
  series:   '50% change'
  setup:    Benches.  setupSerialized50
  before:   Benches. beforeSerialized50
  test:     Benches.       serialized50
  seeds:    [0,0,20,10,0,20,10,10,0,0,10,10,0,0,0,0,10,0,10,0]

suite.bench
  category: 'serialized'
  series:   '25% change'
  setup:    Benches.  setupSerialized25
  before:   Benches. beforeSerialized25
  test:     Benches.       serialized25
  seeds:    [30,50,30,40,40,40,10,30,10,30,50,70,30,0,40,10,40,40,20,20]

suite.bench
  category: 'serialized'
  series:   '12% change'
  setup:    Benches.  setupSerialized12
  before:   Benches. beforeSerialized12
  test:     Benches.       serialized12
  seeds:    [60,70,90,70,80,50,70,40,80,80,30,60,80,80,70,50,90,70,80,30]

suite.bench
  category: 'attributes'
  series:   '50% change'
  setup:    Benches.  setupAttribute50
  before:   Benches. beforeAttribute50
  test:     Benches.       attribute50
  seeds:    [90,60,100,60,80,70,90,90,70,80,80,100,70,90,80,60,70,90,90,80]

suite.bench
  category: 'attributes'
  series:   '25% change'
  setup:    Benches.  setupAttribute25
  before:   Benches. beforeAttribute25
  test:     Benches.       attribute25
  seeds:    [90,100,90,90,100,90,100,100,90,90,100,100,90,90,100,100,100,90,90,80]

suite.bench
  category: 'attributes'
  series:   '12% change'
  setup:    Benches.  setupAttribute12
  before:   Benches. beforeAttribute12
  test:     Benches.       attribute12
  seeds:    [100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100]


