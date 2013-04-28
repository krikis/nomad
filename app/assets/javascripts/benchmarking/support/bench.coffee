class @Bench
  DEFAULT_NR_OF_RUNS: 10
  DEFAULT_TIMEOUT: 1000

  constructor: (options = {}) ->
    @suite      = options.suite
    @measure    = options.measure    || 'mean'
    @category   = options.category   || @uid()
    @series     = options.series     || @uid()
    @setup      = options.setup      || (next) -> next.call(@)
    @setupOpts  = options.setupOpts  || {}
    @before     = options.before     || (next) -> next.call(@)
    @beforeOpts = options.beforeOpts || {}
    @test       = options.test       || (next) -> next.call(@)
    @testOpts   = options.testOpts   || {}
    @after      = options.after      || (next) -> next.call(@)
    @cleanup    = options.cleanup    || (next) -> next.call(@)
    @benchData  = options.data       || 'data70KB'
    @baseline   = options.baseline   || ->
      @success  = true
      @start    = new Date
    @record     = options.record     || ->
      if @success
        @count += 1
        new Date - @start
      else
        0
    @converge   = options.converge   || -> Math.abs(@previous - @current) < @current / 20
    @round      = true
    @round      = options.round      if options.round?
    @unit       = options.unit       || 'ms'
    @unitLong   = options.unitLong   || 'Milliseconds'
    @runs       = options.runs       || @DEFAULT_NR_OF_RUNS
    @timeout    = options.timeout    || @DEFAULT_TIMEOUT
    @chart      = options.chart      if options.chart?
    @seeds      = options.seeds
    @initStats()
    @saveStats()

  initStats: ->
    @key        = "#{@series}_#{@category}"
    @namespace  = @suite?.name || ""
    @stats      = @getStats()

  getStats: ->
    JSON.parse(localStorage["system_#{@namespace}_#{@key}_stats"] || "[]")

  getSeries: ->
    @series

  getCategory: ->
    @category

  saveStats: ->
    localStorage["system_#{@namespace}_#{@key}_stats"] = JSON.stringify @stats

  clearStats: ->
    localStorage["system_#{@namespace}_#{@key}_stats"] = JSON.stringify []

  seed: ->
    @stats = @seeds
    @saveStats()

  run: (options = {}) ->
    @next      = options.next
    @context   = options.context
    @chart     = options.chart   if options.chart?
    @timeout   = options.timeout if options.timeout
    @button    = options.button
    $(@button).attr('disabled': true) if @button?
    @total = 0
    @count = 0
    setTimeout (=>
      try
        @setup.call(@, @testLoop, @setupOpts)
      catch error
        @handleError error
    ), 100

  testLoop: () ->
    setTimeout (=>
      try
        if @count < @runs and not @suite?.stopped()
          @before.call(@, @testFunction, @beforeOpts)
        else
          @cleanup.call(@, @stop)
      catch error
        @handleError error
    ), 100

  testFunction: ->
    setTimeout (=>
      try
        @baseline.call(@)
        @test.call(@, @afterFunction, @testOpts)
      catch error
        @handleError error
    ), 100

  afterFunction: ->
    @total += @record.call(@)
    setTimeout (=>
      try
        @after.call(@, @testLoop)
      catch error
        @handleError error
    ), 100

  stop: ->
    setTimeout (=>
      @processResults()
      $(@button).attr('disabled': false) if @button?
      # return control to next bench if present
      @next?.call(@context, @count > 0)
    ), 100

  restartGracefully: ->
    setTimeout (=>
      try
        @setup.call(@, @testLoop)
      catch error
        @handleError error
    ), 100

  failGracefully: ->
    error = @currentError
    delete @currentError
    @suite?.finish(error)

  handleError: (error)->
    @currentError = error
    try
      @cleanup.call(@, @failGracefully)
    catch error
      @suite?.finish(error)

  processResults: ->
    if @count > 0
      runtime = @total / @count
      @initStats()
      @updateStats(runtime)
      @calculateMeasure()
      @saveStats()

  updateStats: (runtime) ->
    runtime = Math.round runtime if @round
    @suite?.log "[#{@category}] [#{@series}] [#{@count} runs]: #{runtime}"
    @stats.push runtime

  calculateMeasure: ->
    @previous = @[@measure] || 0
    switch @measure
      when 'mean'
        value = Math.mean(@stats)
      when 'median'
        value = Math.median(@stats)
    if @round
      @[@measure] = Math.round(value)
    else
      @[@measure] = value
    @current = @[@measure]

  hasConverged: ->
    @converge.call(@)

  TIMEOUT_INCREMENT: 10

  waitsFor: (check, message, callback) ->
    @_waitFor(check, callback, message, 0)

  _waitFor: (check, callback, message, total) ->
    if check.apply(@)
      callback.apply(@) if _.isFunction(callback)
    else if total >= @timeout
      @suite?.log "Timed out afer #{total} msec waiting for #{message}!"
      # gracefully restart benchmark
      try
        @cleanup.call(@, @restartGracefully)
      catch error
        @handleError error
      return
    else
      total += @TIMEOUT_INCREMENT
      setTimeout (=>
        try
          @_waitFor.apply(@, [check, callback, message, total])
        catch error
          @handleError error
      ), @TIMEOUT_INCREMENT

  # Generate four random hex digits.
  S4 = ->
    (((1 + Math.random()) * 0x10000) | 0).toString(16).substring 1

  # Generate a pseudo-GUID by concatenating random hexadecimal.
  uid: ->
    S4() + S4()


