String::underscore = ->
  out = @
  out = out.replace /([A-Z\d]+)([A-Z][a-z])/g, '$1_$2'
  out = out.replace /([a-z\d])([A-Z])/g, '$1_$2'
  out = out.toLowerCase()
  out