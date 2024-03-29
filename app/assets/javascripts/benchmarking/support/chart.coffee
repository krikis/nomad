class @Chart

  constructor: (options = {})->
    @namespace = options.namespace
    @chartType = options.chartType
    @allSeries = options.allSeries
    @categories = options.categories
    @measure = options.measure
    @chart = new Highcharts.Chart @_chartConfig(options)

  destroy: ->
    @chart?.destroy()

  addBench: (options = {})->
    unless options.category in @categories
      @categories.push options.category
    unless options.series in @allSeries
      seriesAdded = @allSeries.push options.series
    if @chartType == 'finalResults'
      @chart.xAxis[0].setCategories @categories
      if seriesAdded?
        @chart.addSeries
          name: options.series
          data: []
      _.each @chart.series, (series) =>
        while series.data.length < @categories.length
          series.addPoint @_dataPoint(options.data, options.round)
    else
      seriesName = "#{options.series}_#{options.category}"
      unless seriesName in _.map(@chart.series, (series)-> series.name)
        @chart.addSeries
          name: seriesName
          data: @_dataSeries(options.data, options.round)

  addDataPoint: (series, category, data, options = {}) ->
    options.animation = true unless options.animation?
    seriesIndex = _.indexOf(@allSeries, series)
    categoryIndex = _.indexOf(@categories, category)
    if @chartType == 'finalResults'
      @chart.series[seriesIndex].data[categoryIndex].
        update @_dataPoint(data, options.round), true, options.animation
    else
      if options.reset
        @chart.series[categoryIndex * @allSeries.length + seriesIndex].
          setData @_dataSeries(data, options.round)
      else
        if (point = @_dataLinePoint(data, options.round))?
          @chart.series[categoryIndex * @allSeries.length + seriesIndex].
            addPoint point, true, false, options.animation

  clear: (animation = false) ->
    _.each @allSeries, (series) =>
      _.each @categories, (category) =>
        seriesIndex = _.indexOf(@allSeries, series)
        categoryIndex = _.indexOf(@categories, category)
        if @chartType == 'finalResults'
          @chart.series[seriesIndex].data[categoryIndex].
            update 0, true, animation
        else
          @chart.series[categoryIndex * @allSeries.length + seriesIndex].
            setData []

  redraw: (options = {}) ->
    @clear() if options.clear
    setTimeout (=>
        _.each @allSeries, (series) =>
          _.each @categories, (category) =>
            data = options.data[series][category]
            @addDataPoint(series,
                          category,
                          data,
                          round: data?.round
                          animation: options.animation
                          reset: true)
      ), 200

  _dataPoint: (data, round = false) ->
    point = if @measure == 'mean'
      Math.mean(data || [], round)
    else
      Math.median(data || [], round)
    point || 0

  _dataLinePoint: (data, round = false)->
    data ||= []
    if @chartType == 'rawData'
      _.last(data)
    else if @chartType == 'runningMean'
      Math.mean(data, round)
    else
      Math.median(data, round)

  _dataSeries: (data, round = false)->
    data ||= []
    if @chartType == 'rawData'
      data
    else if @chartType == 'runningMean'
      Math.runningMean(data, round)
    else
      Math.runningMedian(data, round)

  _chartConfig: (options = {})->
    config = @_defaultConfig(options)
    if @chartType == 'finalResults'
      config.chart.type = 'bar'
      config.chart.animation =
          duration: 1000
          easing: 'swing'
      config.xAxis =
        categories: @categories
        title:
          text: null
      config.plotOptions =
        bar:
          dataLabels:
            enabled: true
      config.tooltip =
        formatter: ->
          "#{@x} #{@series.name}: #{@y} #{options.unit}"
      config.series = @_chartData(options)
    else
      config.chart.type = 'line'
      config.xAxis =
        tickInterval: 1
        labels:
          enabled: false
      config.tooltip =
        formatter: ->
          "#{@series.name}: #{@y} #{options.unit}"
      config.series = @_lineChartData(options)
    config

  _defaultConfig: (options = {})->
    unit = options.unit
    chart:
      renderTo: "#{options.container}_chartContainer"
      backgroundColor: 'whiteSmoke'
    title:
      text: options.title
    subtitle:
      text: @_extendSubtitle(options.subtitle)
    yAxis:
      min: 0
      max: options.yMax
      title:
        text: "#{options.unit} (#{options.unitLong})"
        align: "high"
      labels:
        overflow: "justify"
    credits:
      enabled: false
    exporting:
      width: 2048

  _extendSubtitle: (subtitle)->
    subtitle += if @chartType == 'finalResults'
      if @measure == 'mean'
        ' [Final Mean]'
      else
        ' [Final Median]'
    else if @chartType == 'rawData'
      ' [Raw Data]'
    else if @chartType == 'runningMean'
      ' [Running Mean]'
    else
      ' [Running Median]'

  _chartData: (options = {})->
    allData = []
    _.each @allSeries, (series) =>
      currentSeries =
        name: series
        data: []
      allData.push currentSeries
      _.each @categories, (category) =>
        data = options.data[series][category]
        currentSeries.data.push @_dataPoint(data, data?.round)
    allData

  _lineChartData: (options = {})->
    allData = []
    _.each @categories, (category) =>
      _.each @allSeries, (series) =>
        data = options.data[series][category]
        currentSeries =
          name: "#{series}_#{category}"
          data: @_dataSeries(data, data?.round)
        allData.push currentSeries
    allData