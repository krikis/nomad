class @Chart
    
  constructor: (options = {})-> 
    @namespace = options.namespace
    @chartType = options.chartType
    @allSeries = options.allSeries
    @categories = options.categories
    @chart = new Highcharts.Chart @_chartConfig(options)
      
  addBench: (options = {})->
    if options.category? and options.category not in @categories
      category = @categories.push options.category
    if options.series? and options.series not in @allSeries
      series = @allSeries.push options.series
    if @chartType == 'finalResults'
      @chart.xAxis[0].setCategories @categories
      if series?
        @chart.addSeries
          name: series
          data: []
      _.each @chart.series, (series) =>
        while series.data.length < @categories.length
          series.addPoint 0
    else if series? or category?
      @chart.addSeries
        name: "#{series}_#{category}"
        data: []
    
  addDataPoint: (series, category, data, animation = true)->  
    seriesIndex = _.indexOf(@allSeries, series)
    categoryIndex = _.indexOf(@categories, category)
    if @chartType == 'finalResults'
      @chart.series[seriesIndex].data[categoryIndex].
        update Math.median(data || []) || 0, true, animation
    else
      point = if @chartType == 'rawData'
        _.last(data)
      else if @chartType == 'runningMean'
        Math.mean(data)
      else
        Math.median(data)
      if point?
        @chart.series[seriesIndex * @categories.length + categoryIndex].
          addPoint point, true, false, animation
        
  clear: (animation = false)->
    _.each @allSeries, (series) =>
      _.each @categories, (category) =>
        if @chartType == 'finalResults'
          @addDataPoint(series, category, [0], animation)
        else
          @addDataPoint(series, category, [], animation)
      
  redraw: (options = {})->
    options.animation ||= true
    @clear()
    setTimeout (=>
        _.each @allSeries, (series) =>
          _.each @categories, (category) =>
            @addDataPoint(series, 
                          category, 
                          options.data[series][category], 
                          options.animation)
      ), 200
      
  _chartConfig: (options = {})->
    config = @_defaultConfig(options)
    if @chartType == 'finalResults'
      config.chart.type = 'bar'
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
      animation:
        duration: 1000
        easing: 'swing'
    title:
      text: options.title
    subtitle:
      text: options.subtitle
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

  _chartData: (options = {})->
    allData = []
    _.each @allSeries, (series) =>
      currentSeries =
        name: series
        data: []
      allData.push currentSeries
      _.each @categories, (category) =>
        data = options.data[series][category]
        currentSeries.data.push Math.median(data || []) || 0
    allData   

  _lineChartData: (options = {})->
    allData = []
    _.each @allSeries, (series) =>
      _.each @categories, (category) =>
        data = options.data[series][category]
        currentSeries =
          name: "#{series}_#{category}"
          data: []
        if data.length > 0
          if @chartType == 'rawData'
            currentSeries.data = data
          else
            _.each [1..data.length], (scope)->
              if @chartType == 'runningMean'
                currentSeries.data.push Math.mean(_.first(data, scope))
              else
                currentSeries.data.push Math.median(_.first(data, scope))
        allData.push currentSeries
    allData