class @Suite
  
  MIN_STABLE_RUNS: 3
  MAX_NR_OF_RUNS: 20
  
  constructor: (options = {}) ->
    @name      = options.name
    @measure   = options.measure   || 'median'
    @benchData = options.benchData
    @benchRuns = options.benchRuns
    @timeout   = options.timeout
    @minStable = options.minStable || @MIN_STABLE_RUNS
    @maxRuns   = options.maxRuns   || @MAX_NR_OF_RUNS
    @baseline  = options.baseline
    @record    = options.record
    @round     = options.round
    @unit      = options.unit      || 'ms'
    @unitLong  = options.unitLong  || 'Milliseconds'
    @benches   = []
    @initChart(options)
    @initButton(options)

  initChart: (options = {}) ->
    @categories = JSON.parse(localStorage["#{@name}_categories"] || "[]")
    @allSeries  = JSON.parse(localStorage["#{@name}_allSeries" ] || "[]")
    if "##{options.container}" == localStorage.current or not localStorage.current?
      @chart = new Highcharts.Chart @chartConfig(options)
    $("a[href='##{options.container}']").click =>
      unless @running
        @chart?.destroy()
        setTimeout (=> 
          @chart = new Highcharts.Chart @chartConfig(options)
        ), 200

  chartConfig: (options = {}) ->
    chart:
      renderTo: "#{options.container}_chartContainer"
      backgroundColor: 'whiteSmoke'
      type: "bar"
    title: 
      text: options.title
    subtitle:
      text: options.subtitle
    xAxis:
      categories: @categories
      title:
        text: null
    yAxis:
      min: 0
      title:
        text: "#{@unit} (#{@unitLong})"
        align: "high"
      labels:
        overflow: "justify"
    tooltip:
      formatter: ->
        "#{@x} #{@series.name}: #{@y} #{@unitLong}"
    plotOptions:
      bar:
        dataLabels:
          enabled: true
    credits:
      enabled: false
    series: @chartData()

  chartData: ->
    allData = []
    _.each @allSeries, (series) =>
      currentSeries = 
        name: series
        data: []
      allData.push currentSeries
      _.each @categories, (category) =>
        currentSeries.data.push(
          JSON.parse(localStorage["#{@name}_#{series}_#{category}_#{@measure}"] || 0)
        )
    allData
    
  initButton: (options = {}) ->
    suite = @
    $("##{options.container} #run").click ->
      unless $(@).attr('disabled')?
        suite.run(@)
    
  bench: (options = {}) ->
    options.suite    = @
    options.chart    ||= @chart
    options.baseline ||= @baseline
    options.record   ||= @record
    options.round    ||= @round
    options.unit     ||= @unit
    options.unitLong ||= @unitLong
    bench = new Bench options
    @benches.push bench
    
  run: (button) ->
    @running = true
    @button = button
    $(@button).attr('disabled': true) if @button?
    @saveChartSetup()
    @runs = 1
    @stableRuns = 0
    @benchIndex = 0
    console.log '================================= Suite      ================================='
    @runBench()
    
  saveChartSetup: ->
    localStorage["#{@name}_categories"] = JSON.stringify @categories
    localStorage["#{@name}_allSeries" ] = JSON.stringify @allSeries
    
  runBench: ->
    if bench = @benches[@benchIndex]
      setTimeout (=>
        bench.run
          next:    @nextBench
          context: @
          chart: @chart
          measure: @measure
          data:    @benchData
          runs:    @benchRuns
          timeout:  @timeout
      ), 500
    
  nextBench: ->
    bench = @benches[@benchIndex]
    # let iteration converge when oscillations become smaller than 1%
    if Math.abs(bench.previous - bench[@measure]) > bench[@measure] / 100
      @rerunSuite = true
    @benchIndex++
    if @benchIndex < @benches.length
      @runBench()
    else
      @runSuite()
      
  runSuite: ->
    @stableRuns++ unless @rerunSuite
    @rerunSuite = true if @stableRuns < @minStable
    if @rerunSuite and @runs < @maxRuns
      @rerunSuite = false
      @runs++
      @benchIndex = 0
      @runBench()
    else
      @finish()
    
  finish: (timeout = false)->
    @running = false
    unless timeout
      if @runs < @maxRuns
        console.log "converged after #{@runs} iterations"
      else
        console.log "maximum number of runs reached"
      console.log new Date
      console.log @benchData if @benchData?
      console.log JSON.stringify @categories
      console.log JSON.stringify @chartData()
      _.each @benches, (bench) =>
        key = "#{bench.namespace}_#{bench.key}_stats"
        console.log key
        console.log localStorage[key]
    $(@button).attr('disabled': false) if @button?  