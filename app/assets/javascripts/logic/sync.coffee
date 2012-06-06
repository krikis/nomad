@Sync =
  preSync: ->
    @fayeClient.publish
      versions: @versionDetails()

  versionDetails: () ->
    models = @modelsForSync()
    _(models).chain().map((model) ->
      details =
        id: model.id
        version: model.version()
      details['is_new'] = true unless model.isSynced()
      details
    ).value()

  modelsForSync: (options = {}) ->
    _(@models).filter (model) ->
      model.markAsSynced() if options.markSynced
      model.hasPatches()

  dataForSync: (options = {}) ->
    models = @modelsForSync(options)
    _(models).chain().map((model) ->
      json = model.toJSON()
      delete json.id
      id: model.id
      attributes: json
      version: model.version()
    ).value()

  processUpdates: (models) ->
    _.map models, (attributes, id) =>
      model = @get(id)
      model?.rebase attributes

  syncModels: (updated) ->
    @fayeClient.publish
      updates: @dataForSync(markSynced: true)

# extend Backbone.Collection
_.extend Backbone.Collection::, Sync