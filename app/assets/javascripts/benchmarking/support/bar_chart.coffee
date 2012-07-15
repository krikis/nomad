@allSeries = JSON.parse localStorage.allSeries || "[]"
@categories = JSON.parse localStorage.categories || "[]"
@allData = JSON.parse(localStorage.allData || "[]")

@barChartConfig =
  chart:
    renderTo: "barChart"
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

  series: @allData