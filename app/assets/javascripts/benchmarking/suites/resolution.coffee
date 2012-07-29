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
  series:   'quiet'
  setup:    Benches.  setupAttributeLooseQuiet
  before:   Benches. beforeAttributeLooseQuiet
  test:     Benches.       attributeLooseQuiet
  
suite.bench
  category: 'serialized'
  series:   'quiet'
  setup:    Benches.  setupSerializedLooseQuiet
  before:   Benches. beforeSerializedLooseQuiet
  test:     Benches.       serializedLooseQuiet
  
suite.bench
  category: 'attribute'
  series:   'chaos'
  setup:    Benches.  setupAttributeLooseChaos
  before:   Benches. beforeAttributeLooseChaos
  test:     Benches.       attributeLooseChaos
  
suite.bench
  category: 'serialized'
  series:   'chaos'
  setup:    Benches.  setupSerializedLooseChaos
  before:   Benches. beforeSerializedLooseChaos
  test:     Benches.       serializedLooseChaos
