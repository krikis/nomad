suite = @memory = new Suite
  name:      'memory'
  container: 'tab3'
  title:     'Content Duplication vs. Patch Chain'
  subtitle:  'Memory footprint for different versioning strategies'
  baseline:  ->
  record:    ->
    (JSON.stringify(@answer._versioning.patches).length / JSON.stringify(@answer.attributes).length) * 100
  unit:      '% (Portion of data)'
  
suite.bench
  category: 'content'
  series:   'versioning'
  setup:    Benches.  setupContent
  before:   Benches. beforeContent
  test:     Benches.       content
  
suite.bench
  category: 'patch'
  series:   'versioning'
  setup:    Benches.  setupPatch
  before:   Benches. beforePatch
  test:     Benches.       patch
  
  