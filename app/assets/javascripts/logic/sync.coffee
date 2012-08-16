@Sync =
  # compile a message for preventive reconciliation and publish it
  preSync: ->
    message =
      new_versions: @_versionDetails(@_newModels())
      versions: @_versionDetails(@_dirtyModels())
    @fayeClient.publish message

  # collect a model's guid and vector clock
  _versionDetails: (models) ->
    _(models).chain().map((model) ->
      id: model.id
      version: model.version()
    ).value()

  # fetch all models that have never been synced before
  _newModels: () ->
    _(@models).filter (model) ->
      model.hasPatches() and not model.isSynced()

  # fetch all models that have local changes
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

  # sync the data of all models containing local changes
  syncModels: (options = {}) ->
    message =
      updates: @_dataForSync(@_dirtyModels())
      creates: @_dataForSync(@_newModels(), markSynced: true)
    # if there are any local changes or 
    # remote changes have not been fetched recently
    unless options['afterPresync']? and
           _.isEmpty(message.updates) and
           _.isEmpty(message.creates)
      @fayeClient.publish message

  # collect all data that has to be synced to the server
  _dataForSync: (models, options = {}) ->
    _(models).chain().map((model) ->
      json = model.toJSON()
      # mark data version as being synced
      model.updateSyncingVersions()
      delete json.id
      # collect data for sync
      details =
        id: model.id
        attributes: json
        version: model.version()
        created_at: model.createdAt()
        updated_at: model.updatedAt()
      # mark object as synced
      if options.markSynced
        model.markAsSynced()
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
    @_cleanLocalStorage()
    @fayeClient.client.disconnect?()
    
  _cleanLocalStorage: ->
    @fetch()
    _.each _.clone(@models), (model) ->
      model.destroy()
    @localStorage._cleanup()

# extend Backbone.Collection
_.extend Backbone.Collection::, Sync