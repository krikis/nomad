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
    
  guid = ->
    S4() + S4() + "-" + S4() + "-" + S4() + "-" + S4() + "-" + S4() + S4() + S4()
    
  Backbone.LocalStorage = window.Store = (name) ->
    @name = name
    store = @localStorage().getItem(@name)
    @records = (store and store.split(",")) or []

  _.extend Backbone.LocalStorage::,
    save: ->
      @localStorage().setItem @name, @records.join(",")

    create: (model) ->
      model.id = model.attributes[model.idAttribute] = guid()  unless model.id
      @localStorage().setItem @name + "-" + model.id, JSON.stringify(model)
      @records.push model.id.toString()
      @save()
      model

    update: (model) ->
      @localStorage().setItem @name + "-" + model.id, JSON.stringify(model)
      @records.push model.id.toString()  unless _.include(@records, model.id.toString())
      @save()
      model

    find: (model) ->
      JSON.parse @localStorage().getItem(@name + "-" + model.id)

    findAll: ->
      _(@records).chain().map((id) ->
        JSON.parse @localStorage().getItem(@name + "-" + id)
      , this).compact().value()

    destroy: (model) ->
      @localStorage().removeItem @name + "-" + model.id
      @records = _.reject(@records, (record_id) ->
        record_id is model.id.toString()
      )
      @save()
      model

    localStorage: ->
      localStorage

  Backbone.LocalStorage.sync = window.Store.sync = Backbone.localSync = (method, model, options, error) ->
    store = model.localStorage or model.collection.localStorage
    if typeof options is "function"
      options =
        success: options
        error: error
    resp = undefined
    switch method
      when "read"
        resp = (if model.id isnt `undefined` then store.find(model) else store.findAll())
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

  Backbone.sync = (method, model, options, error) ->
    Backbone.getSyncMethod(model).apply this, [ method, model, options, error ]
)()