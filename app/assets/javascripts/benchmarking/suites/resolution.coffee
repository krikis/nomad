suite = @resolution = new Suite
  name:      'resolution'
  container: 'tab4'
  title:     'Patching Serialized Objects vs. Rebasing Individual Attributes'
  subtitle:  'Outcome of the reconciliation process'
  yMax:      100
  baseline:  ->
  record:    ->
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
  seeds:    [0,20,0,20,10,10,10,10,0,10,10,0,10,20,10,50,10,20,10,20,0,10,10,10,20,0,0,30,30,10,20,0,0,10,0,0,10,20,30,20,30,10,0,10,0,10,10,20,10,0,30,10,0,20,10,0,30,0,20,10,20,10,20,20,20,10,10,20,0,0,10]

suite.bench
  category: 'serialized'
  series:   '25% change'
  setup:    Benches.  setupSerialized25
  before:   Benches. beforeSerialized25
  test:     Benches.       serialized25
  seeds:    [30,0,20,20,30,20,20,30,20,40,20,20,50,40,20,60,60,50,20,30,30,50,40,40,30,30,30,30,20,30,30,40,20,50,50,30,40,50,30,40,40,20,40,70,50,40,40,40,30,30,0,50,30,10,30,20,50,60,60,10,60,30,30,40,30,50,30,60,60,40,40]

suite.bench
  category: 'serialized'
  series:   '12% change'
  setup:    Benches.  setupSerialized12
  before:   Benches. beforeSerialized12
  test:     Benches.       serialized12
  seeds:    [30,50,60,30,0,40,60,60,80,20,20,50,70,100,50,30,40,50,10,20,20,60,70,70,20,40,60,50,0,20,40,70,60,50,30,50,60,50,60,80,60,40,60,70,70,50,50,50,70,60,40,50,50,40,20,30,30,40,60,50,80,70,20,70,50,40,50,80,30,50,50]

suite.bench
  category: 'attributes'
  series:   '50% change'
  setup:    Benches.  setupAttribute50
  before:   Benches. beforeAttribute50
  test:     Benches.       attribute50
  seeds:    [100,70,80,70,90,100,50,70,80,100,80,80,70,100,40,60,80,70,80,80,50,60,90,80,70,70,80,100,90,50,80,90,70,90,90,90,90,80,80,70,60,60,80,60,50,90,80,80,90,70,80,100,80,90,70,80,70,70,80,70,50,90,70,50,80,50,90,70,80,70,70]

suite.bench
  category: 'attributes'
  series:   '25% change'
  setup:    Benches.  setupAttribute25
  before:   Benches. beforeAttribute25
  test:     Benches.       attribute25
  seeds:    [100,100,100,100,100,100,100,90,90,100,90,80,100,100,90,100,90,100,100,100,100,100,100,100,90,100,90,90,90,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,90,100,90,100,100,100,100,100,80,100,90,100,100,90,90,100,100,100,100]

suite.bench
  category: 'attributes'
  series:   '12% change'
  setup:    Benches.  setupAttribute12
  before:   Benches. beforeAttribute12
  test:     Benches.       attribute12
  seeds:    [100,100,90,90,100,100,100,100,90,100,100,100,100,100,90,100,100,100,90,100,100,90,100,100,100,100,100,100,100,90,100,100,100,100,100,100,100,100,100,100,100,90,100,100,100,100,100,90,100,100,90,100,100,90,100,100,100,100,100,100,100,100,100,100,100,100,100,90,100,100,100]


