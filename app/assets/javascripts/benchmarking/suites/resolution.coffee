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
  series:   'strict_chaos'
  setup:    Benches.  setupAttributeRandom
  before:   Benches. beforeAttributeRandom
  test:     Benches.       attributeRandom
  
suite.bench
  category: 'serialized'
  series:   'strict_chaos'
  setup:    Benches.  setupSerializedRandom
  before:   Benches. beforeSerializedRandom
  test:     Benches.       serializedRandom
  
suite.bench
  category: 'attribute'
  series:   'loose_chaos'
  setup:    Benches.  setupAttributeLooseChaos
  before:   Benches. beforeAttributeLooseChaos
  test:     Benches.       attributeLooseChaos
  
suite.bench
  category: 'serialized'
  series:   'loose_chaos'
  setup:    Benches.  setupSerializedLooseChaos
  before:   Benches. beforeSerializedLooseChaos
  test:     Benches.       serializedLooseChaos
