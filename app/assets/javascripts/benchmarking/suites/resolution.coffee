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
  series:   'loose_quiet'
  setup:    Benches.  setupAttributeLooseQuiet
  before:   Benches. beforeAttributeLooseQuiet
  test:     Benches.       attributeLooseQuiet
  
suite.bench
  category: 'serialized'
  series:   'loose_quiet'
  setup:    Benches.  setupSerializedLooseQuiet
  before:   Benches. beforeSerializedLooseQuiet
  test:     Benches.       serializedLooseQuiet
  
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
  
suite.bench
  category: 'attribute'
  series:   'strict_quiet'
  setup:    Benches.  setupAttributeStrictQuiet
  before:   Benches. beforeAttributeStrictQuiet
  test:     Benches.       attributeStrictQuiet
  
suite.bench
  category: 'serialized'
  series:   'strict_quiet'
  setup:    Benches.  setupSerializedStrictQuiet
  before:   Benches. beforeSerializedStrictQuiet
  test:     Benches.       serializedStrictQuiet
  
suite.bench
  category: 'attribute'
  series:   'strict_chaos'
  setup:    Benches.  setupAttributeStrictChaos
  before:   Benches. beforeAttributeStrictChaos
  test:     Benches.       attributeStrictChaos
  
suite.bench
  category: 'serialized'
  series:   'strict_chaos'
  setup:    Benches.  setupSerializedStrictChaos
  before:   Benches. beforeSerializedStrictChaos
  test:     Benches.       serializedStrictChaos
