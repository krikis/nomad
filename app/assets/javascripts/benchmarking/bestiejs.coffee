#= require benchmarking/benchmark.js
#= require_self

@suite = suite = new Benchmark.Suite
reportingSuite = new Benchmark.Suite

suite.add("RegExp#test", (->
    /o/.test "Hello World!"
  ),
    'onStart': (event) -> 
    'onComplete': (event) -> console.log String(event.target)
)

suite.add("String#indexOf", (->
    "Hello World!".indexOf("o") > -1
  ),
    'onStart': (event) -> 
    'onComplete': (event) -> console.log String(event.target)
)

suite.on("cycle", (event) ->
  
)

suite.on("complete", ->
  console.log "Fastest is " + reportingSuite.filter("fastest").pluck('name')
)

# $('#run').click ->
_.each suite, (bench) ->
  reportingSuite.push bench
suite.run 
  async: true
  queued: true