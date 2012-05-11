@Observer =
  bindTo: (source, event, callback) ->
    source.on event, callback, @
    @bindings ||= _([])
    @bindings.push source

  unbindFromAll: ->
    if @bindings?
      @bindings.each (source) ->
        source.off null, null, @
      @bindings = _([])
      
# extend Backbone.View
_.extend Backbone.View::,   @Observer