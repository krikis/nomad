Math.mean ||= (data, round = false)->
  if data.length > 0
    sum = _.reduce data, (memo, value) -> memo + value
    out = sum / data.length
    if round?
      Math.round(out)
    else
      out
    
Math.runningMean ||= (data, round = false)->
  out = []
  if data.length > 0
    _.each [1..data.length], (scope)->
      out.push Math.mean(_.first(data, scope), round)
  out
    
Math.median ||= (data, round = false)->
  data = data.slice().sort(Sort.numerical)
  length = data.length
  if data.length > 0
    out = if data.length % 2 == 0
      (data[(length / 2) - 1] + data[(length / 2)]) / 2
    else
      data[Math.round(length / 2) - 1]
    if round?
      Math.round(out)
    else
      out

Math.runningMedian ||= (data, round = false)->
  out = []
  if data.length > 0
    _.each [1..data.length], (scope)->
      out.push Math.median(_.first(data, scope), round)
  out
    
Sort = {}
Sort.numerical ||= (a, b) ->
    a - b