@Sync =
  preSync: ->
    message =
      new_versions: @_versionDetails(@_newModels())
      versions: @_versionDetails(@_dirtyModels())
    @fayeClient.publish message

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

  lastSynced: () ->
    @localStorage.lastSynced

  setLastSynced: (timestamp) ->
    unless @localStorage.lastSynced == timestamp
      @localStorage.lastSynced = timestamp
      @localStorage.save()

  handleCreates: (models) ->
    _(models).chain().map((attributes, id) =>
      if model = @get(id)
        model.processCreate attributes
      else
        @_processCreate id, attributes
    ).compact().value()

  _processCreate: (id, attributes) ->
    attributes.id = id
    [version, created_at, updated_at] =
      @_extractVersioning(attributes)
    model = @create attributes
    model.setVersion(version, created_at, updated_at)
    model.markAsSynced()
    model.save()
    null

  _extractVersioning: (attributes) ->
    version = attributes.remote_version
    delete attributes.remote_version
    created_at = attributes.created_at
    delete attributes.created_at
    updated_at = attributes.updated_at
    delete attributes.updated_at
    [version, created_at, updated_at]

  handleUpdates: (models) ->
    _(models).chain().map((attributes, id) =>
      if model = @get(id)
        model.processUpdate attributes
      else
        @_processCreate id, attributes
    ).compact().value()

  # sync all dirty models
  syncModels: (options = {}) ->
    message =
      updates: @_dataForSync(@_dirtyModels())
      creates: @_dataForSync(@_newModels(), markSynced: true)
    unless options['afterPresync']? and
           _.isEmpty(message.updates) and
           _.isEmpty(message.creates)
      @fayeClient.publish message

  _dataForSync: (models, options = {}) ->
    _(models).chain().map((model) ->
      json = model.toJSON()
      delete json.id
      details =
        id: model.id
        attributes: json
        version: model.version()
        created_at: model.createdAt()
        updated_at: model.updatedAt()
      if options.markSynced
        model.markAsSynced()
      model.updateSyncingVersions()
      model.save()
      details
    ).value()

  # sync all processed models
  syncProcessed: (processed) ->
    message =
      updates: @_dataForSync(processed.updates)
      creates: @_dataForSync(processed.creates)
    unless _.isEmpty(message.updates) and
           _.isEmpty(message.creates)
      @fayeClient.publish message

  leave: (channel) ->
    @fayeClient.unsubscribe(channel)
   
  # test convenience method for cleaning up localstorage 
  _cleanup: ->
    @fayeClient.client.disconnect()
    @_cleanLocalStorage()
    
  _cleanLocalStorage: ->
    @fetch()
    _.each _.clone(@models), (model) ->
      model.destroy()
    @localStorage._cleanup()

# extend Backbone.Collection
_.extend Backbone.Collection::, Sync