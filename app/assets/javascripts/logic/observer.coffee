@Observer =
  bindTo: (source, event, callback) ->
    source.on event, callback, @
    @bindings ||= _([])
    @bindings.push source
      
  leave: ->
    @unbind()
    @unbindFromAll()
    @remove()

  unbindFromAll: ->
    @bindings.each (source) ->
      source.off null, null, @
    @bindings = _([])