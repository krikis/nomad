class @Bench
  DEFAULT_NR_OF_RUNS: 10
  
  constructor: (options = {}) ->
    @category = options.category || @uid()
    @series   = options.series   || @uid()
    @setup    = options.setup    || (next) -> next.call(@)
    @before   = options.before   || (next) -> next.call(@)
    @test     = options.test     || (next) -> next.call(@)
    @after    = options.after    || (next) -> next.call(@)
    @cleanup  = options.cleanup  || (next) -> next.call(@)
    @runs     = options.runs     || @DEFAULT_NR_OF_RUNS
    @chart    = options.chart
    @initStats()
    @initChart()
    
  initStats: ->    
    @mean = 0
    @key = "#{@series}_#{@category}"
    @stats = JSON.parse(localStorage[@key] || "[]")
    @categories = JSON.parse(localStorage.categories || "[]")
    unless @category in @categories
      @categories.push @category 
      @categories.push "#{@category}_median"
      @newCategory = true
    @allSeries = JSON.parse(localStorage.allSeries || "[]")
    unless @series in @allSeries
      @allSeries.push @series
      @newSeries = true
    @saveStats()
    
  initChart: ->
    if @newSeries
      @chart.addSeries
        name: @series  
        data: []
    if @newCategory
      @chart.xAxis[0].setCategories @categories
    _.each @chart.series, (series) =>
      while series.data.length < @categories.length
        series.addPoint 0
    
  saveStats: ->
    localStorage[@key] = JSON.stringify @stats
    localStorage.categories = JSON.stringify @categories
    localStorage.allSeries = JSON.stringify @allSeries
    
  run: (options = {}) ->
    @next = options.next
    @suite = options.context
    @button = options.button
    $(@button).attr('disabled': true) if @button?
    @timeout = false
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
    console.log "#{@key}: #{@runs} runs in #{@total} ms"
    @processResults()
    $(@button).attr('disabled': false) if @button?
    # return control to suite if present
    @next?.call(@suite)
    
  processResults: ->  
    runtime = if @runs > 0 then @total / @runs else 0
    @updateStats(runtime)
    @redrawChart()   
    
  updateStats: (runtime) ->   
    @stats.push runtime
    @saveStats()
    if _.isEmpty(@stats)
      mean = 0
      median = 0
    else
      sum = _.reduce @stats, (memo, value) -> memo + value
      mean = sum / @stats.length
      stats = @stats.sort((a, b) -> a - b)
      length = stats.length
      if stats.length % 2 == 0
        median = (stats[(length / 2) - 1] + stats[(length / 2)]) / 2
      else
        median = stats[Math.round(length / 2) - 1]
    @previous = @median
    @mean = Math.round mean    
    @median = Math.round median
    
  redrawChart: ->
    seriesIndex = _.indexOf(@allSeries, @series)
    categoryIndex = _.indexOf(@categories, @category)
    @chart.series[seriesIndex].data[categoryIndex].update @mean
    medianIndex = _.indexOf(@categories, "#{@category}_median")
    @chart.series[seriesIndex].data[medianIndex].update @median
    @cacheChartData()
    
  cacheChartData: ->
    @allData = JSON.parse(localStorage.allData || "[]")
    @allData[seriesIndex] ||=
      name: @series
      data: []
    @allData[seriesIndex].data[categoryIndex] = @mean  
    @allData[seriesIndex].data[medianIndex] = @median
    localStorage.allData = JSON.stringify @allData
    
  TIMEOUT_INCREMENT: 10

  waitsFor: (check, message, timeout, callback) ->
    @_waitFor(check, callback, message, timeout, 0)

  _waitFor: (check, callback, message, timeout, total) ->
    if check.apply(@)
      callback.apply(@) if _.isFunction(callback)
    else if total >= timeout
      console.log "Timed out afer #{total} msec waiting for #{message}!"
      # gracefully stop
      $(@button).attr('disabled': false) if @button?
      @suite?.finish(true)
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
  uid: ->
    S4() + S4()
  
  
    