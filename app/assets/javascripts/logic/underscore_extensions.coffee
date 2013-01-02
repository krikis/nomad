# returns all properties owned by an object that are not functions
_.properties ||= (obj) ->
  throw new TypeError("Invalid object")  if obj isnt Object(obj)
  properties = []
  for key of obj
    properties[properties.length] = key  if _.has(obj, key) and not _.isFunction(obj[key])
  properties
  
# note that this clone function only goes into recursion 
# for objects and not for arrays!!!
_.deepClone ||= (obj) ->
  return obj  unless _.isObject(obj)
  (if _.isArray(obj) then obj.slice() else _.deepExtend({}, obj))
  
_.deepExtend ||= (obj) ->  
  _.each Array.prototype.slice.call(arguments, 1), (source) ->
    for prop of source
      obj[prop] = _.deepClone source[prop]
  obj
  
_.prettyInspect ||= (object, name='Object') ->
  "-------------------#{name}-------------------\n" +
  _.map(_.properties(object).sort(), (property)->
    "- #{property}: #{object[property]}"
  ).join('\n')
  