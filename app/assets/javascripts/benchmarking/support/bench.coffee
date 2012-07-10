class @Bench
  DEFAULT_NR_OF_RUNS: 10
  
  constructor: (options) ->
    @name     = options.name    || @guid()
    @setup    = options.setup   || (next) -> next.call(@)
    @before   = options.before  || (next) -> next.call(@)
    @test     = options.test    || (next) -> next.call(@)
    @after    = options.after   || (next) -> next.call(@)
    @cleanup  = options.cleanup || (next) -> next.call(@)
    @runs     = options.runs    || @DEFAULT_NR_OF_RUNS
    @stats    = JSON.parse(localStorage[@name]   || "[]")
    @allStats = JSON.parse(localStorage.allStats || "[]")
    @allStats.push @name unless @name in @allStats
    @save()
    
  run: (button) ->
    @button = button
    $(@button).attr('disabled': true)
    @total = 0
    @count = @runs
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
    if @count < 0 # all runs performed
      console.log "#{@runs} runs in #{@total} ms"
      runtime = @total / @runs
      
      @stats.push runtime
      @save()
    $(@button).attr('disabled': false)
    
  save: ->
    localStorage[@name] = JSON.stringify @stats
    localStorage.allStats = JSON.stringify @allStats
    
  TIMEOUT_INCREMENT: 10

  waitsFor: (check, message, timeout, callback) ->
    @_waitFor(check, callback, message, timeout, 0)

  _waitFor: (check, callback, message, timeout, total) ->
    if check.apply(@)
      callback.apply(@) if _.isFunction(callback)
    else if total >= timeout
      console.log "Timed out afer #{total} msec waiting for #{message}!"
      return
    else
      total += @TIMEOUT_INCREMENT
      setTimeout (=>
        @_waitFor.apply(@, [check, callback, message, timeout, total])
      ), @TIMEOUT_INCREMENT
      
  # Generate four random hex digits.
  S4 = ->
    (((1 + Math.random()) * 0x10000) | 0).toString(16).substring 1
    
  # Generate a pseudo-GUID by concatenating random hexadecimal.
  guid: ->
    S4() + S4() + "-" + S4() + "-" + S4() + "-" + S4() + "-" + S4() + S4() + S4()
  
  
    