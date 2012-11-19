Math.mean ||= (data)->
  if data.length > 0
    sum = _.reduce data, (memo, value) -> memo + value
    sum / data.length
    
Math.median ||= (data)->
  data = data.slice().sort(Sort.numerical)
  length = data.length
  if data.length > 0
    if data.length % 2 == 0
      (data[(length / 2) - 1] + data[(length / 2)]) / 2
    else
      data[Math.round(length / 2) - 1]
    
Sort = {}
Sort.numerical ||= (a, b) ->
    a - b