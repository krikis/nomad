suite = @memory = new Suite
  name:      'memory'
  container: 'tab3'
  title:     'Content Duplication vs. Patch Chain'
  subtitle:  'Memory footprint for different versioning strategies'
  baseline:  ->
  record:    ->
    (JSON.stringify(@answer._versioning.patches).length / JSON.stringify(@answer.attributes).length) * 100
  unit:      '%'
  unitLong:  'Portion of data'
  
suite.bench
  category: 'content'
  series:   '3 versions'
  setup:    Benches.  setupContent3
  before:   Benches. beforeContent3
  test:     Benches.       content3
  
suite.bench
  category: 'patch'
  series:   '3 versions'
  setup:    Benches.  setupPatch3
  before:   Benches. beforePatch3
  test:     Benches.       patch3
  
suite.bench
  category: 'content'
  series:   '6 versions'
  setup:    Benches.  setupContent6
  before:   Benches. beforeContent6
  test:     Benches.       content6
  
suite.bench
  category: 'patch'
  series:   '6 versions'
  setup:    Benches.  setupPatch6
  before:   Benches. beforePatch6
  test:     Benches.       patch6
  
suite.bench
  category: 'content'
  series:   '12 versions'
  setup:    Benches.  setupContent12
  before:   Benches. beforeContent12
  test:     Benches.       content12
  
suite.bench
  category: 'patch'
  series:   '12 versions'
  setup:    Benches.  setupPatch12
  before:   Benches. beforePatch12
  test:     Benches.       patch12
  
  