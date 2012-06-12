@Sync =
  preSync: ->
    @fayeClient.publish
      new_versions: @_versionDetails(@_newModels())
      versions: @_versionDetails(@_dirtyModels())

  _versionDetails: (models) ->
    _(models).chain().map((model) ->
      id: model.id
      version: model.version()
    ).value()

  _newModels: () ->
    _(@models).filter (model) ->
      model.hasPatches() and not model.isSynced()

  _dirtyModels: () ->
    _(@models).filter (model) ->
      model.hasPatches() and model.isSynced()

  handleUpdates: (models) ->
    _.map models, (attributes, id) =>
      model = @get(id)
      model?.processUpdate attributes

  syncModels: (updated) ->
    @fayeClient.publish
      updates: @_dataForSync(@_dirtyModels())
      creates: @_dataForSync(@_newModels(), markSynced: true)

  _dataForSync: (models, options = {}) ->
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