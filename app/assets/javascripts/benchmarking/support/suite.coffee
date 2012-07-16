class @Suite
  constructor: (options={}) ->
    @name      = options.name
    @chart     = options.chart
    @chart?.setTitle({text: options.title},
                     {text: options.subtitle})
    @measure   = options.measure || 'median'
    @benchData = options.benchData
    @benchRuns = options.benchRuns
    @timeout   = options.timeout
    @benches   = []
    @initChart()

  initChart: () ->
    @categories = JSON.parse(localStorage["#{@name}_categories"] || "[]")
    @allSeries  = JSON.parse(localStorage["#{@name}_allSeries" ] || "[]")
    @chart = new Highcharts.Chart @chartConfig()

  chartConfig: ->
    chart:
      renderTo: "chartContainer"
      type: "bar"
    xAxis:
      categories: @categories
      title:
        text: null
    yAxis:
      min: 0
      title:
        text: "ms (Milliseconds)"
        align: "high"
      labels:
        overflow: "justify"
    tooltip:
      formatter: ->
        "#{@x} #{@series.name}: #{@y} milliseconds"
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
    
  bench: (options) ->
    options.suite = @
    options.chart ||= @chart
    bench = new Bench options
    @benches.push bench
    
  MAX_NR_OF_RUNS: 20
  MIN_STABLE_RUNS: 3
    
  run: (button) ->
    @button = button
    $(@button).attr('disabled': true) if @button?
    @saveChartSetup()
    @runs = 1
    @stableRuns = 0
    @benchIndex = 0
    @runBench()
    
  saveChartSetup: ->
    localStorage["#{@name}_categories"] = JSON.stringify @categories
    localStorage["#{@name}_allSeries" ] = JSON.stringify @allSeries
    
  runBench: ->
    if bench = @benches[@benchIndex]
      bench.run
        next:    @nextBench
        context: @
        measure: @measure
        data:    @benchData
        runs:    @benchRuns
        timeout:  @timeout
    
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
    @rerunSuite = true if @stableRuns < @MIN_STABLE_RUNS
    if @rerunSuite and @runs < @MAX_NR_OF_RUNS
      @rerunSuite = false
      @runs++
      @benchIndex = 0
      @runBench()
    else
      @finish()
    
  finish: (timeout = false)->
    unless timeout
      if @runs < @MAX_NR_OF_RUNS
        console.log "converged after #{@runs} iterations"
      else
        console.log "maximum number of runs reached"
      console.log new Date
      console.log @benchData
      console.log JSON.stringify localStorage
    $(@button).attr('disabled': false) if @button?  