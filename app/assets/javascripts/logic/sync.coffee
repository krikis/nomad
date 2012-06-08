@Sync =
  preSync: ->
    @fayeClient.publish
      new_versions: @_versionDetails(@_newModelsForSync())
      versions: @_versionDetails(@_modelsForSync())

  _versionDetails: (models) ->
    _(models).chain().map((model) ->
      id: model.id
      version: model.version()
    ).value()
    
  _newModelsForSync: () ->
    _(@models).filter (model) ->
      model.hasPatches() and not model.isSynced()

  _modelsForSync: () ->
    _(@models).filter (model) ->
      model.hasPatches() and model.isSynced()

  processUpdates: (models) ->
    _.map models, (attributes, id) =>
      model = @get(id)
      model?.handleUpdate attributes

  syncModels: (updated) ->
    @fayeClient.publish
      updates: @_dataForSync(markSynced: true)

  _dataForSync: (options = {}) ->
    models = @_modelsForSync()
    _(models).chain().map((model) ->
      json = model.toJSON()
      delete json.id
      details = 
        id: model.id
        attributes: json
        version: model.version()
      model.markAsSynced() if options.markSynced
      details
    ).value()

# extend Backbone.Collection
_.extend Backbone.Collection::, Sync