class @Bench
  DEFAULT_NR_OF_RUNS: 10
  DEFAULT_TIMEOUT: 1000

  constructor: (options = {}) ->
    @suite    = options.suite
    @measure  = options.measure  || @suite?.measure
    @category = options.category || @uid()
    @series   = options.series   || @uid()
    @setup    = options.setup    || (next) -> next.call(@)
    @before   = options.before   || (next) -> next.call(@)
    @test     = options.test     || (next) -> next.call(@)
    @after    = options.after    || (next) -> next.call(@)
    @cleanup  = options.cleanup  || (next) -> next.call(@)
    @baseline = options.baseline || -> @start = new Date
    @record   = options.record   || -> new Date - @start
    @round    = true
    @round    = options.round    if options.round?
    @unit     = options.unit
    @unitLong = options.unitLong
    @runs     = options.runs     || @DEFAULT_NR_OF_RUNS
    @timeout  = options.timeout  || @DEFAULT_TIMEOUT
    @chart    = options.chart    if options.chart?
    @seeds    = options.seeds
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
    @benchData = options.data    || 'data70KB'
    @runs      = options.runs    if options.runs
    @timeout   = options.timeout if options.timeout
    @button    = options.button
    $(@button).attr('disabled': true) if @button?
    @total = 0
    @count = 0
    setTimeout (=>
      try
        @setup.call(@, @testLoop)
      catch error
        @handleError error
    ), 100

  testLoop: () ->
    setTimeout (=>
      try
        if @count < @runs and not @suite?.stopped() 
          @before.call(@, @testFunction)
          @count++
        else
          @cleanup.call(@, @stop)
      catch error
        @handleError error
    ), 100

  testFunction: ->
    setTimeout (=>
      try
        @baseline.call(@)
        @test.call(@, @afterFunction)
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
    
  handleError: (error)->
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


