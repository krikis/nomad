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
  seeds:    [0,20,20,10,0,10,10,20,0,20,10,20,10,10,10,20,30,40,0,20,10,10,0,0,10,10,10,20,10,0,0,30,20,10]

suite.bench
  category: 'serialized'
  series:   '25% change'
  setup:    Benches.  setupSerialized25
  before:   Benches. beforeSerialized25
  test:     Benches.       serialized25
  seeds:    [20,30,40,60,30,30,20,50,60,50,20,50,20,30,40,40,70,40,20,10,30,40,40,40,60,50,50,40,70,70,70,50,30,30]

suite.bench
  category: 'serialized'
  series:   '12% change'
  setup:    Benches.  setupSerialized12
  before:   Benches. beforeSerialized12
  test:     Benches.       serialized12
  seeds:    [50,40,50,40,40,40,50,30,50,50,80,10,30,60,30,30,30,60,50,50,40,30,60,60,40,70,30,60,40,50,60,40,70,40]

suite.bench
  category: 'attributes'
  series:   '50% change'
  setup:    Benches.  setupAttribute50
  before:   Benches. beforeAttribute50
  test:     Benches.       attribute50
  seeds:    [80,70,70,90,90,100,70,70,80,90,60,80,60,90,70,50,60,70,90,80,80,70,100,70,60,80,60,50,70,60,50,90,70,70]

suite.bench
  category: 'attributes'
  series:   '25% change'
  setup:    Benches.  setupAttribute25
  before:   Benches. beforeAttribute25
  test:     Benches.       attribute25
  seeds:    [100,100,100,100,100,90,100,100,90,100,100,90,90,100,90,100,100,100,100,100,100,100,100,100,100,100,100,100,80,100,100,90,100,100]

suite.bench
  category: 'attributes'
  series:   '12% change'
  setup:    Benches.  setupAttribute12
  before:   Benches. beforeAttribute12
  test:     Benches.       attribute12
  seeds:    [100,100,100,100,100,100,100,100,100,100,100,90,100,100,100,100,90,100,100,100,100,100,100,100,90,100,100,100,100,100,100,100,100,100]


