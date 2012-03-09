Observer =
  bindTo: (source, event, callback) ->
    source.on event, callback, this
    @bindings = @bindings or []
    @bindings.push
      source: source
      event: event
      callback: callback

  unbindFromAll: ->
    _.each @bindings, (binding) ->
      binding.source.off binding.event, binding.callback

    @bindings = []