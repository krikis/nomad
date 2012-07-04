#= require benchmarking/benchmark.js
#= require_self

suite = new Benchmark.Suite

suite.add("RegExp#test", ->
  /o/.test "Hello World!"
)

suite.add("String#indexOf", ->
  "Hello World!".indexOf("o") > -1
)

suite.on("cycle", (event) ->
  console.log String(event.target)
)

suite.on("complete", ->
  console.log "Fastest is " + @filter("fastest").pluck("name")
)

$('#run').click ->
  suite.run async: true