_.properties = (obj) ->
  throw new TypeError("Invalid object")  if obj isnt Object(obj)
  properties = []
  for key of obj
    properties[properties.length] = key  if _.has(obj, key) and not _.isFunction(obj[key])
  properties