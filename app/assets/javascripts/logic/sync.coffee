@Sync =
  prepareSync: ->
    @fayeClient.publish
      client_id: Nomad.clientId
      model_name: @modelName
      objects: @changedModels()

  changedModels: ->
    _(@models).chain().map((model) ->
      if model.hasPatches()
        id: model.id
        old_version: model._versioning?.oldVersion
    ).compact().value()
    
  processUpdates: (models) ->
    updated = _.map models, (attributes, id) =>
      model = @get(id)
      model?.rebase attributes
    @syncModels _(updated).compact()
    
  syncModels: (models) ->

# extend Backbone.Collection
_.extend Backbone.Collection::, Sync