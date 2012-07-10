@allSeries = JSON.parse localStorage.allSeries || "[]"
@categories = JSON.parse localStorage.categories || "[]"
@allData = _.map @allSeries, (series) =>
  name: series
  data: _.map(@categories, (category) ->
    key = "#{series}_#{category}"
    values = JSON.parse(localStorage[key] || "[]")
    if _.isEmpty values
      mean = 0
    else
      sum = _.reduce values, (memo, value) -> memo + value
      mean = sum / values.length
    Math.round(mean)
  )

@barChartConfig =
  chart:
    renderTo: "barChart"
    type: "bar"

  title:
    text: "Duration of Sync Operation"

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

  series: @allData