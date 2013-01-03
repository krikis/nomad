class @Suite
  
  MIN_NR_OF_RUNS: 20
  MIN_STABLE_RUNS: 5
  MAX_NR_OF_RUNS: 50

  constructor: (options = {}) ->
    @name      = options.name
    @container = options.container
    @title     = options.title
    @subtitle  = options.subtitle
    @yMax      = options.yMax
    @measure   = options.measure   || 'mean'
    @benchData = options.benchData
    @benchRuns = options.benchRuns
    @timeout   = options.timeout
    @minRuns   = options.minRuns   || @MIN_NR_OF_RUNS
    @minStable = options.minStable || @MIN_STABLE_RUNS
    @maxRuns   = options.maxRuns   || @MAX_NR_OF_RUNS
    @baseline  = options.baseline
    @record    = options.record
    @round     = options.round
    @unit      = options.unit      || 'ms'
    @unitLong  = options.unitLong  || 'Milliseconds'
    @benches   = []
    @_initChartSetup()
    @_drawChart()
    @initButtons()

  bench: (options = {}) ->
    options.suite       = @
    options.chart     ||= @chart
    options.baseline  ||= @baseline
    options.record    ||= @record
    unless options.round?
      options.round     = @round
    options.unit      ||= @unit
    options.unitLong  ||= @unitLong
    options.measure   ||= @measure
    options.benchData ||= @benchData
    bench = new Bench options
    @benches.push bench
    category = bench.getCategory()
    series = bench.getSeries()
    unless category in @categories
      @categories.push category 
    unless series in @allSeries
      @allSeries.push series
    @_saveChartSetup()
    @chart?.addBench
      data: bench.getStats()
      series: series
      category: category

  _initChartSetup: ->
    @chartType = localStorage["system_#{@name}_chartType"] || 'runningMean'
    @categories = []
    @allSeries  = []
    
  _saveChartSetup: ->  
    localStorage["system_#{@name}_chartType"] = @chartType

  _drawChart: ->
    if not localStorage.system_current? and $("##{@container}").hasClass('active')
      @chart?.destroy()
      @chart = new Chart(@_chartOptions())
    $("a[href='##{@container}']").click =>
      unless @running
        if not @chart?
          setTimeout (=>   
              @chart = new Chart(@_chartOptions())
            ), 200
        else
          @chart.redraw(data: @_chartData(), clear: true)

  _chartOptions: ->  
    namespace: @name
    chartType: @chartType
    round: @round
    measure: @measure
    container: @container
    title: @title
    subtitle: @subtitle
    yMax: @yMax
    unit: @unit
    unitLong: @unitLong
    allSeries: @allSeries.slice()
    categories: @categories.slice()
    data: @_chartData()
    
  _chartData: ->
    data = {}
    _.each @benches, (bench) ->
      data[bench.getSeries()] ||= {}
      data[bench.getSeries()][bench.getCategory()] = bench.getStats()
    data

  rawData: ->
    @chartType = 'rawData'
    @_saveChartSetup()
    @chart?.destroy()
    @chart = new Chart(@_chartOptions())
    
  runningMedian: ->
    @chartType = 'runningMedian'
    @_saveChartSetup()
    @chart?.destroy()
    @chart = new Chart(@_chartOptions())
    
  runningMean: ->
    @chartType = 'runningMean'
    @_saveChartSetup()
    @chart?.destroy()
    @chart = new Chart(@_chartOptions())
    
  finalResults: ->
    @chartType = 'finalResults'
    @_saveChartSetup()
    @chart?.destroy()
    @chart = new Chart(@_chartOptions())
    
  initButtons: ->  
    $("##{@container} ##{@chartType}").find('i').addClass('icon-ok')
    suite = @
    $("##{@container} .run").click ->
      unless $(@).attr('disabled')?
        suite.run(@)
    $("##{@container} #rawData").click ->
      $(@).parent().parent().find('i').removeClass('icon-ok')
      $(@).find('i').addClass('icon-ok')
      suite.rawData()
    $("##{@container} #runningMean").click ->
      $(@).parent().parent().find('i').removeClass('icon-ok')
      $(@).find('i').addClass('icon-ok')
      suite.runningMean()
    $("##{@container} #runningMedian").click ->
      $(@).parent().parent().find('i').removeClass('icon-ok')
      $(@).find('i').addClass('icon-ok')
      suite.runningMedian()
    $("##{@container} #finalResults").click ->
      $(@).parent().parent().find('i').removeClass('icon-ok')
      $(@).find('i').addClass('icon-ok')
      suite.finalResults()
    $("##{@container} #stop").click ->
      unless $(@).attr('disabled')?
        suite.stop(@)
    $("##{@container} #clear").click ->
      unless $(@).attr('disabled')?
        suite.clear(@)
    $("##{@container} #seed").click ->
      unless $(@).attr('disabled')?
        suite.seed(@)

  setButtons: (button) ->
    container    = $(button).parent().parent().parent()
    @stopButton  ||= container.find('#stop')
    @clearButton ||= container.find('#clear')
    @seedButton  ||= container.find('#seed')

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
    _.each @benches, (bench) ->
      bench.clearStats()
    @chart.clear(true)
    @clearButton?.attr('disabled': false)

  seed: (button) ->
    @setButtons button
    @seedButton?.attr('disabled': true)
    _.each @benches, (bench) ->
      bench.seed()
    @chart.redraw(data: @_chartData())
    @seedButton?.attr('disabled': false)

  run: (button) ->
    @running = true
    @setButtons button
    @buttonsForRunning()
    @runs = 1
    @stableRuns = 0
    @benchIndex = 0
    # console.log '================================= Suite      ================================='
    @log "Suite started..."
    @runBench()

  runBench: ->
    @clearStorage()
    if @running and bench = @benches[@benchIndex]
      bench.run
        next:    @nextBench
        context: @
        chart:   @chart
        runs:    @benchRuns
        timeout: @timeout
    else
      setTimeout (=>
        @finish()
      ), 50

  nextBench: (updateChart = true)->
    bench = @benches[@benchIndex]
    unless bench.hasConverged()
      @rerunSuite = true
      @stableRuns = 0
    if updateChart
      @chart.addDataPoint(bench.getSeries(),
                          bench.getCategory(),
                          bench.getStats())
    @benchIndex++
    if @benchIndex < @benches.length
      @runBench()
    else
      @runSuite()

  runSuite: ->
    @stableRuns++ unless @rerunSuite
    if @runs < @minRuns or @stableRuns < @minStable
      @rerunSuite = true 
    if @rerunSuite and @runs < @maxRuns
      @rerunSuite = false
      @runs++
      @benchIndex = 0
      @runBench()
    else
      setTimeout (=>
          @finish()
        ), 1000

  finish: (error = undefined) ->
    if error?
      @log(error)
    else if not @running
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
        _.each @benches, (bench) =>
          @log "#{bench.namespace}_#{bench.key}::#{JSON.stringify bench.getStats()}"
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



