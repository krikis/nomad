class @Suite
  constructor: (options = {}) ->
    @name      = options.name
    @measure   = options.measure || 'median'
    @benchData = options.benchData
    @benchRuns = options.benchRuns
    @timeout   = options.timeout
    @benches   = []
    @initChart(options)
    @initButton(options)

  initChart: (options = {}) ->
    @categories = JSON.parse(localStorage["#{@name}_categories"] || "[]")
    @allSeries  = JSON.parse(localStorage["#{@name}_allSeries" ] || "[]")
    if "##{options.container}" == localStorage.current
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
    
  initButton: (options = {}) ->
    suite = @
    $("##{options.container} #run").click ->
      suite.run(@)
    
  bench: (options = {}) ->
    options.suite = @
    options.chart ||= @chart
    bench = new Bench options
    @benches.push bench
    
  MAX_NR_OF_RUNS: 20
  MIN_STABLE_RUNS: 3
    
  run: (button) ->
    @running = true
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
        chart: @chart
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
    @running = false
    unless timeout
      if @runs < @MAX_NR_OF_RUNS
        console.log "converged after #{@runs} iterations"
      else
        console.log "maximum number of runs reached"
      console.log new Date
      console.log @benchData
      console.log JSON.stringify localStorage
    $(@button).attr('disabled': false) if @button?  