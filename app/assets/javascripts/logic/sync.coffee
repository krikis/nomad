@Sync =
  prepareSync: ->
    @fayeClient.publish
      client_id: Nomad.clientId
      model_name: @modelName
      objects: @changedObjects()

  changedObjects: ->
    _(@models).chain().map((model) ->
      if model.hasPatches()
        id: model.id
        old_version: model._versioning?.oldVersion
    ).compact().value()
    
  processUpdates: (models)->
    _.each models, (attributes, id) =>
      model = @get(id)
      model?.rebase attributes

# extend Backbone.Collection
_.extend Backbone.Collection::, Sync