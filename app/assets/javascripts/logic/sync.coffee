@Sync =
  preSync: ->
    @fayeClient.publish
      versions: @_versionDetails()

  _versionDetails: () ->
    models = @_modelsForSync()
    _(models).chain().map((model) ->
      id: model.id
      version: model.version()
      is_new: !model.isSynced()
    ).value()

  _modelsForSync: () ->
    _(@models).filter (model) ->
      model.hasPatches()

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
        is_new: !model.isSynced()
      model.markAsSynced() if options.markSynced
      details
    ).value()

# extend Backbone.Collection
_.extend Backbone.Collection::, Sync