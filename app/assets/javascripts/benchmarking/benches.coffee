#= require_tree ./support
#= require_tree ./benches
#= require_self

bench = new Bench
  setup:   (next) -> console.log 'setup'   ; next.call(@)
  before:  (next) -> console.log 'before'  ; next.call(@)
  test:    (next) -> console.log 'test'    ; next.call(@)
  after:   (next) -> console.log 'after'   ; next.call(@)
  cleanup: (next) -> console.log 'cleanup' ; next.call(@)
  

$('#run').click ->
  bench.run()
