suite = @resolution = new Suite
  name:      'resolution'
  container: 'tab4'
  title:     'Attribute Resolution vs. Serialized Object'
  subtitle:  'Success rates for different conflict resolution strategies'
  baseline:  ->
  record:    ->
    @success * 100
  unit:      '%'
  unitLong:  'Success rate'
  # benchRuns: 1
  # maxRuns:   1

suite.bench
  category: 'attribute'
  series:   '12% change'
  setup:    Benches.  setupAttribute12
  before:   Benches. beforeAttribute12
  test:     Benches.       attribute12
  seeds:    [100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100]

suite.bench
  category: 'serialized'
  series:   '12% change'
  setup:    Benches.  setupSerialized12
  before:   Benches. beforeSerialized12
  test:     Benches.       serialized12
  seeds:    [10,20,20,30,30,40,40,40,40,40,40,40,50,50,50,50,50,50,50,60,60,60,60,60,60,60,60,60,60,60,70,70,70,80,90,90]

suite.bench
  category: 'attribute'
  series:   '25% change'
  setup:    Benches.  setupAttribute25
  before:   Benches. beforeAttribute25
  test:     Benches.       attribute25
  seeds:    [80,90,90,90,90,90,90,90,90,90,90,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100,100]

suite.bench
  category: 'serialized'
  series:   '25% change'
  setup:    Benches.  setupSerialized25
  before:   Benches. beforeSerialized25
  test:     Benches.       serialized25
  seeds:    [10,10,20,20,20,20,30,30,30,30,30,30,30,30,30,40,40,40,40,50,50,50,50,50,50,50,50,50,50,50,60,60,60,60,60,70]

suite.bench
  category: 'attribute'
  series:   '50% change'
  setup:    Benches.  setupAttribute50
  before:   Benches. beforeAttribute50
  test:     Benches.       attribute50
  seeds:    [40,40,50,50,60,60,60,60,60,70,70,70,70,70,70,70,70,70,70,80,80,80,80,80,80,80,80,80,80,90,90,90,90,90,90,90]

suite.bench
  category: 'serialized'
  series:   '50% change'
  setup:    Benches.  setupSerialized50
  before:   Benches. beforeSerialized50
  test:     Benches.       serialized50
  seeds:    [0,0,0,0,0,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,20,20,20,20,20,20,20,20,20,20,20,20,20,30,30,30]


