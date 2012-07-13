class @Bench
  DEFAULT_NR_OF_RUNS: 10
  DEFAULT_TIMEOUT: 1000
  
  constructor: (options = {}) ->
    @category = options.category || @uid()
    @series   = options.series   || @uid()
    @setup    = options.setup    || (next) -> next.call(@)
    @before   = options.before   || (next) -> next.call(@)
    @test     = options.test     || (next) -> next.call(@)
    @after    = options.after    || (next) -> next.call(@)
    @cleanup  = options.cleanup  || (next) -> next.call(@)
    @runs     = options.runs     || @DEFAULT_NR_OF_RUNS
    @timeout  = options.timeout  || @DEFAULT_TIMEOUT
    @chart    = options.chart
    @initStats()
    @initChart()
    @saveStats()
    
  initStats: ->    
    @mean = 0
    @key = "#{@series}_#{@category}"
    @stats = JSON.parse(localStorage[@key] || "[]")
    @categories = JSON.parse(localStorage.categories || "[]")
    @allSeries = JSON.parse(localStorage.allSeries || "[]")
    @allData = JSON.parse(localStorage.allData || "[]")
    
  initChart: ->  
    unless @series in @allSeries
      @allSeries.push @series
      @chart.addSeries
        name: @series  
        data: []
    unless @category in @categories
      @categories.push @category 
      @chart.xAxis[0].setCategories @categories
    seriesIndex = 0
    _.each @chart.series, (series) =>
      @allData[seriesIndex] ||= 
        name: series.name
        data: []
      categoryIndex = 0
      _.each @chart.xAxis[0].categories, (category) =>
        @allData[seriesIndex].data[categoryIndex] ||= 0
        categoryIndex++
      seriesIndex++
      while series.data.length < @categories.length
        series.addPoint 0
    
  saveStats: ->
    localStorage[@key] = JSON.stringify @stats.sort(@numerical)
    localStorage.categories = JSON.stringify @categories
    localStorage.allSeries = JSON.stringify @allSeries
    localStorage.allData = JSON.stringify @allData
    
  run: (options = {}) ->
    @next      = options.next
    @suite     = options.context
    @measure   = options.measure
    @benchData = options.data    || 'data70KB'
    @runs      = options.runs    if options.runs
    @timeout   = options.timeout if options.timeout
    @button    = options.button
    $(@button).attr('disabled': true) if @button?
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
    @initStats()
    @updateStats(runtime)
    @redrawChart()   
    @saveStats()
    
  updateStats: (runtime) ->   
    @stats.push Math.round runtime
    @previous = @[@measure] || 0
    switch @measure
      when 'mean' 
        sum = _.reduce @stats, (memo, value) -> memo + value
        @[@measure] = Math.round(sum / @stats.length)
      when 'median'
        stats = @stats.sort(@numerical)
        length = stats.length
        if stats.length % 2 == 0
          value = (stats[(length / 2) - 1] + stats[(length / 2)]) / 2
        else
          value = stats[Math.round(length / 2) - 1]
        @[@measure] = Math.round(value)
    
  redrawChart: ->
    seriesIndex = _.indexOf(@allSeries, @series)
    categoryIndex = _.indexOf(@categories, @category)
    @chart.series[seriesIndex].data[categoryIndex].update @[@measure]
    # cache chart data
    @allData[seriesIndex] ||=
      name: @series
      data: []
    @allData[seriesIndex].data[categoryIndex] = @[@measure]
    
  benchmarkData: ->
    switch @benchData
      when 'data70KB'
        Benches['data70KB']
      when 'data140KB'
        Benches['data70KB'] + 
        Benches['data70KB']
      when 'data280KB'
        Benches['data70KB'] + 
        Benches['data70KB'] +
        Benches['data70KB'] +
        Benches['data70KB']
      when 'data560KB'
        Benches['data70KB'] + 
        Benches['data70KB'] +
        Benches['data70KB'] +
        Benches['data70KB'] +
        Benches['data70KB'] + 
        Benches['data70KB'] +
        Benches['data70KB'] +
        Benches['data70KB']
      when 'data1120KB'
        Benches['data70KB'] + 
        Benches['data70KB'] +
        Benches['data70KB'] +
        Benches['data70KB'] +
        Benches['data70KB'] + 
        Benches['data70KB'] +
        Benches['data70KB'] +
        Benches['data70KB'] +
        Benches['data70KB'] + 
        Benches['data70KB'] +
        Benches['data70KB'] +
        Benches['data70KB'] +
        Benches['data70KB'] + 
        Benches['data70KB'] +
        Benches['data70KB'] +
        Benches['data70KB']
    
  TIMEOUT_INCREMENT: 10

  waitsFor: (check, message, callback) ->
    @_waitFor(check, callback, message, 0)

  _waitFor: (check, callback, message, total) ->
    if check.apply(@)
      callback.apply(@) if _.isFunction(callback)
    else if total >= @timeout
      console.log "Timed out afer #{total} msec waiting for #{message}!"
      # gracefully stop
      $(@button).attr('disabled': false) if @button?
      @suite?.finish(true)
      return
    else
      total += @TIMEOUT_INCREMENT
      setTimeout (=>
        @_waitFor.apply(@, [check, callback, message, total])
      ), @TIMEOUT_INCREMENT
      
  # Generate four random hex digits.
  S4 = ->
    (((1 + Math.random()) * 0x10000) | 0).toString(16).substring 1
    
  # Generate a pseudo-GUID by concatenating random hexadecimal.
  uid: ->
    S4() + S4()
    
  numerical: (a, b) ->
    a - b
  
  
    