@Sync = 
  prepareSync: ->
    @fayeClient.publish {locks: @objectLocks()}
    
  objectLocks: ->
    _(@models).chain().map((model) ->
      model.id if model.hasPatches()
    ).compact().value()
    
# extend Backbone.Collection
_.extend Backbone.Collection::, Sync