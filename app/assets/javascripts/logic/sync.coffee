@Sync =
  prepareSync: ->
    @fayeClient.publish
      model: @channel
      object_ids: @changedObjects()

  changedObjects: ->
    _(@models).chain().map((model) ->
      model.id if model.hasPatches()
    ).compact().value()

# extend Backbone.Collection
_.extend Backbone.Collection::, Sync