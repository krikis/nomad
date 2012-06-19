@Sync =
  preSync: ->
    message = 
      new_versions: @_versionDetails(@_newModels())
      versions: @_versionDetails(@_dirtyModels())
    unless _.isEmpty(message.new_versions) and 
           _.isEmpty(message.versions)
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
    model.setVersion(version, updated_at)
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
  syncModels: () ->
    message = 
      updates: @_dataForSync(@_dirtyModels())
      creates: @_dataForSync(@_newModels(), markSynced: true)
    unless _.isEmpty(message.updates) and 
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
      model.markAsSynced() if options.markSynced
      details
    ).value()
    
  # sync all processed models
  syncProcessed: (processed) ->
    unless _.isEmpty(processed.updates) and 
           _.isEmpty(processed.creates)
      @fayeClient.publish processed

# extend Backbone.Collection
_.extend Backbone.Collection::, Sync