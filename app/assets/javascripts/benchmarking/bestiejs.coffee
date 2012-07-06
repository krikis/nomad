#= require benchmarking/benchmark.js
#= require_tree ./benches
#= require_self

@suite = suite  = new Benchmark.Suite

suite.add
  name:       "Sync Create"
  setup:      'Benches.beforeSyncCreate()'
  fn:         'Benches.syncCreate()'
  teardown:   'Benches.afterSyncCreate()'
  onStart:    (event) ->
    console.log "Starting #{event.target.name}"
  onComplete: (event) -> console.log String(event.target)

suite.add("String#indexOf", (->
    "Hello World!".indexOf("o") > -1
  ),
    'onStart': (event) -> console.log "Starting #{event.target.name}"
    'onComplete': (event) -> console.log String(event.target)
)

suite.on("cycle", (event) ->

)

suite.on("complete", ->
  console.log "Fastest is " + @filter("fastest").pluck('name')
)

# $('#run').click ->
suite.run
  async: true