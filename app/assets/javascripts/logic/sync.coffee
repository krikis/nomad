@Sync =
  preSync: ->
    @fayeClient.publish
      versions: @versionDetails()

  versionDetails: () ->
    models = @modelsForSync()
    _(models).chain().map((model) ->
      id: model.id
      version: model.version()
      is_new: !model.isSynced()
    ).value()

  modelsForSync: () ->
    _(@models).filter (model) ->
      model.hasPatches()

  dataForSync: (options = {}) ->
    models = @modelsForSync()
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

  processUpdates: (models) ->
    _.map models, (attributes, id) =>
      model = @get(id)
      model?.handleUpdate attributes

  syncModels: (updated) ->
    @fayeClient.publish
      updates: @dataForSync(markSynced: true)

# extend Backbone.Collection
_.extend Backbone.Collection::, Sync