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
    @initButtons(options)

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

  initChart: (options = {}) ->
    @container = options.container
    @categories = JSON.parse(localStorage["system_#{@name}_categories"] || "[]")
    @allSeries  = JSON.parse(localStorage["system_#{@name}_allSeries" ] || "[]")
    if not localStorage.system_current? and $("##{@container}").hasClass('active')
      @chart = new Highcharts.Chart @chartConfig(options)
    $("a[href='##{@container}']").click =>
      unless @running
        @resetChart(options)

  resetChart: (options = {}) ->
    if @chart?
      seriesIndex = 0
      _.each @allSeries, (series) =>
        categoryIndex = 0
        _.each @categories, (category) =>
          @chart.series[seriesIndex].data[categoryIndex].update 0, true, false
          categoryIndex++
        seriesIndex++
    setTimeout (=>
      if @chart?
        _.each @benches, (bench) =>
          bench.redrawChart
            chart: @chart
            animation:
              duration: 1000
              easing: 'swing'
      else
        @chart = new Highcharts.Chart @chartConfig(options)
    ), 200

  chartConfig: (options = {}) ->
    unit = @unit
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
      max: options.yMax
      title:
        text: "#{@unit} (#{@unitLong})"
        align: "high"
      labels:
        overflow: "justify"
    tooltip:
      formatter: ->
        "#{@x} #{@series.name}: #{@y} #{unit}"
    plotOptions:
      bar:
        dataLabels:
          enabled: true
    credits:
      enabled: false
    series: @chartData()
    exporting:
      width: 2048

  chartData: ->
    allData = []
    _.each @allSeries, (series) =>
      currentSeries =
        name: series
        data: []
      allData.push currentSeries
      _.each @categories, (category) =>
        currentSeries.data.push(
          JSON.parse(localStorage["system_#{@name}_#{series}_#{category}_#{@measure}"] || 0)
        )
    allData

  initButtons: (options = {}) ->
    suite = @
    $("##{options.container} .run").click ->
      unless $(@).attr('disabled')?
        suite.run(@)
    $("##{options.container} #stop").click ->
      unless $(@).attr('disabled')?
        suite.stop(@)
    $("##{options.container} #clear").click ->
      unless $(@).attr('disabled')?
        suite.clear(@)
    $("##{options.container} #seed").click ->
      unless $(@).attr('disabled')?
        suite.seed(@)

  setButtons: (button) ->
    container    = $(button).parent()
    @stopButton  ||= container.children('#stop')
    @clearButton ||= container.children('#clear')
    @seedButton  ||= container.children('#seed')

  buttonsForRunning: ->
    $('.run').attr('disabled': true)
    @clearButton?.attr('disabled': true)
    @seedButton?.attr('disabled': true)
    @stopButton?.attr('disabled': false)

  buttonsForIdle: ->
    @stopButton?.attr('disabled': true)
    $('.run').attr('disabled': false)
    @clearButton?.attr('disabled': false)
    @seedButton?.attr('disabled': false)

  stop: (button) ->
    @running = false
    @setButtons button
    @buttonsForIdle()
    
  stopped: ->
    not @running

  clear: (button) ->
    @setButtons button
    @clearButton?.attr('disabled': true)
    seriesIndex = 0
    _.each @allSeries, (series) =>
      categoryIndex = 0
      _.each @categories, (category) =>
        localStorage["system_#{@name}_#{series}_#{category}_#{@measure}"] = 0
        localStorage["system_#{@name}_#{series}_#{category}_stats"] = "[]"
        @chart.series[seriesIndex].data[categoryIndex].update 0, true
          animation:
            duration: 1000
            easing: 'swing'
        categoryIndex++
      seriesIndex++
    @clearButton?.attr('disabled': false)

  seed: (button) ->
    @setButtons button
    @seedButton?.attr('disabled': true)
    @saveChartSetup()
    _.each @benches, (bench) =>
      bench.seed
        chart: @chart
    @seedButton?.attr('disabled': false)

  run: (button) ->
    @running = true
    @setButtons button
    @buttonsForRunning()
    @saveChartSetup()
    @runs = 1
    @stableRuns = 0
    @benchIndex = 0
    # console.log '================================= Suite      ================================='
    @log "Suite started..."
    @runBench()

  saveChartSetup: ->
    localStorage["system_#{@name}_categories"] = JSON.stringify @categories
    localStorage["system_#{@name}_allSeries" ] = JSON.stringify @allSeries

  runBench: ->
    @clearStorage()
    if @running
      if bench = @benches[@benchIndex]
        bench.run
          next:    @nextBench
          context: @
          chart:   @chart
          measure: @measure
          data:    @benchData
          runs:    @benchRuns
          timeout: @timeout
    else
      setTimeout (=>
        @finish()
      ), 50

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
      setTimeout (->
          @finish()
        ), 1000

  finish: (timeout = false) ->
    unless timeout
      if not @running
        @log "Suite stopped"
      else if @runs < @maxRuns
        @log "Converged after #{@runs} iterations"
      else
        @log "Maximum number of runs reached"
      setTimeout (=>  
          @log "=================== Results ========================"
          @log new Date
          @log @benchData if @benchData?
          @log JSON.stringify @categories
          @log JSON.stringify @chartData()
          _.each @benches, (bench) =>
            key = "system_#{bench.namespace}_#{bench.key}_stats"
            @log key
            @log localStorage[key]
        ), 2000
    @running = false
    @buttonsForIdle()
    
  clearStorage: ->
    _.each _.properties(localStorage), (property) ->
      unless /^system_/.test property
        localStorage.removeItem(property)

  log: (message) ->
    @logTop ||= 38
    @logTop -= 28
    @modal ||= $("##{@container}_logModal .modal-body")
    @logging ||= $("##{@container} .log")
    last = @logging.children(':last')
    @modal.prepend $("<span>#{message}</span>")
    @logging.append $("<span>#{message}</span>")
    @logging.animate(
      {top: "#{@logTop}px"},
      {complete: ->
          last.css('color', 'white')
      }
    )
    console.log message



