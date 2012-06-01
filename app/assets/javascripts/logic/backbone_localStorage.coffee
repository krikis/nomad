#
# Backbone localStorage Adapter
# Adapted from https://github.com/jeromegn/Backbone.localStorage
#

(->
  # A simple module to replace `Backbone.sync` with *localStorage*-based
  # persistence. Models are given GUIDS, and saved into a JSON object. Simple
  # as that.

  # Generate four random hex digits.
  S4 = ->
    (((1 + Math.random()) * 0x10000) | 0).toString(16).substring 1

  # Our Store is represented by a single JS object in *localStorage*. Create it
  # with a meaningful name, like the name you'd give a table.
  # window.Store is deprectated, use Backbone.LocalStorage instead
  Backbone.LocalStorage = window.Store = (name) ->
    @name = name
    store = @localStorage().getItem(@name)
    @records = (store and store.split(",")) or []
    return

  _.extend Backbone.LocalStorage::,

    # Save the current state of the **Store** to *localStorage*.
    save: ->
      @localStorage().setItem @name, @records.join(",")
      return

    # Generate a pseudo-GUID by concatenating random hexadecimal.
    guid: ->
      S4() + S4() + "-" + S4() + "-" + S4() + "-" + S4() + "-" + S4() + S4() + S4()

    # Generates the key a model is stored with in localStorage
    storageKeyFor: (model) ->
      "#{@name}-#{if _.isObject(model) then model.id else model}"

    # Generates the key a model's versioning is stored with in localStorage
    versioningKeyFor: (model) ->
      "#{@storageKeyFor(model)}-versioning"

    # Add a model, giving it a (hopefully)-unique GUID, if it doesn't already
    # have an id of it's own.
    create: (model) ->
      unless model.id
        new_id = @guid()
        # make sure the id is unique within the model's collection
        new_id = @guid() while @find(id: new_id)?
        model.set(model.idAttribute, new_id)
      @localStorage().setItem @storageKeyFor(model), JSON.stringify(model)
      @records.push model.id.toString()
      @save()
      model

    # Update a model by replacing its copy in `@data`.
    update: (model) ->
      @localStorage().setItem @storageKeyFor(model), JSON.stringify(model)
      @saveVersioningFor(model)
      unless _.include(@records, model.id.toString())
        @records.push model.id.toString()
      @save()
      model

    saveVersioningFor: (model) ->
      model.initVersioning()
      @localStorage().setItem @versioningKeyFor(model),
                              JSON.stringify(model._versioning)

    # Retrieve a model from `@data` by id.
    find: (model) ->
      @setVersioning(model)
      JSON.parse @localStorage().getItem(@storageKeyFor model)

    # Return the array of all models currently in storage.
    findAll: (collection) ->
      collection?.on 'reset', @setAllVersioning, @
      collection?.on 'add', @setVersioning, @
      _(@records).chain().map((id) ->
        JSON.parse @localStorage().getItem(@storageKeyFor id)
      , @).compact().value()

    setAllVersioning: (collection, options) ->
      _.each(collection.models, (model) =>
        @setVersioning model
      )

    setVersioning: (model) ->
      versioning = JSON.parse @localStorage().
                  getItem(@versioningKeyFor model)
      model._versioning = versioning if versioning?

    # Delete a model from `@data`, returning it.
    destroy: (model) ->
      @localStorage().removeItem @versioningKeyFor(model)
      @localStorage().removeItem @storageKeyFor(model)
      @records = _.reject(@records, (record_id) ->
        record_id is model.id.toString()
      )
      @save()
      model

    localStorage: ->
      localStorage

  # localSync delegate to the model or collection's
  # *localStorage* property, which should be an instance of `Store`.
  # window.Store.sync and Backbone.localSync is deprectated, use Backbone.LocalStorage.sync instead
  Backbone.LocalStorage.sync = window.Store.sync = Backbone.localSync = (method, model, options, error) ->
    store = model.localStorage or model.collection.localStorage

    # Backwards compatibility with Backbone <= 0.3.3
    if typeof options is "function"
      options =
        success: options
        error: error

    resp = undefined

    switch method
      when "read"
        resp = (if model.id isnt `undefined` then store.find(model) else store.findAll(model))
      when "create"
        resp = store.create(model)
      when "update"
        resp = store.update(model)
      when "delete"
        resp = store.destroy(model)

    if resp
      options.success resp
    else
      options.error "Record not found"

  Backbone.ajaxSync = Backbone.sync

  Backbone.getSyncMethod = (model) ->
    return Backbone.localSync  if model.localStorage or (model.collection and model.collection.localStorage)
    Backbone.ajaxSync

  # Override 'Backbone.sync' to default to localSync,
  # the original 'Backbone.sync' is still available in 'Backbone.ajaxSync'
  Backbone.sync = (method, model, options, error) ->
    return Backbone.getSyncMethod(model).apply @, [ method, model, options, error ]

  return
)()