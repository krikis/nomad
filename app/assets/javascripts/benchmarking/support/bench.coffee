class @Bench
  DEFAULT_NR_OF_RUNS: 10
  
  constructor: (options) ->
    @setup   = options.setup   || (next) -> next.call(@)
    @before  = options.before  || (next) -> next.call(@)
    @test    = options.test    || (next) -> next.call(@)
    @after   = options.after   || (next) -> next.call(@)
    @cleanup = options.cleanup || (next) -> next.call(@)
    @count = @runs = options.count || @DEFAULT_NR_OF_RUNS
    
  run: ->
    @total = 0
    @setup.call(@, @testLoop)
    
  testLoop: () ->
    if @count--
      @before.call(@, @testFunction)
    else
      @cleanup.call(@, @stop)
      
  testFunction: ->
    @start = new Date
    @test.call(@, @afterFunction)
    
  afterFunction: ->
    @time = new Date - @start
    @total += @time
    @after.call(@, @testLoop)
    
  stop: ->
    console.log "#{@runs} runs in #{@total} ms"
    
  
    