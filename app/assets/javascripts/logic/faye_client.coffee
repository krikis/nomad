@BackboneSync ||= {}

class @BackboneSync.FayeClient
  constructor: (collection, options) ->
    Faye.Logging.logLevel = if window.development then 'info' else 'error'
    window.client ||= new Faye.Client("http://nomad.dev:9292/faye")
    # disable all non-websocket after connection to enforce websockets
    # client.disable('long-polling'); 
    # client.disable('cross-origin-long-polling'); 
    # client.disable('callback-polling');
    @client = window.client
    @collection = collection
    @modelName = options.modelName
    @subscribe()

  publish: (message)->  
    message.client_id ||= Nomad.clientId
    message.model_name ||= @modelName
    @client.publish "/server/" + @modelName, message

  subscribe: ->
    @client.subscribe "/sync/#{@modelName}", @receive, @
    @client.subscribe "/sync/#{@modelName}/#{Nomad.clientId}", @receive, @

  receive: (message) ->
    meta = message.meta
    delete message.meta
    _.each message, (eventArguments, event) =>
      @[event] eventArguments
    @collection.syncModels() if meta?.preSync

  update: (params) ->
    @collection.processUpdates(params)
    
  resolve: (params) ->

  create: (params) ->
    _.each params, (attributes, id) =>
      model = new @collection.model(attributes)
      @collection.create model

  destroy: (params) ->
    _.each params, (attributes, id) =>
      model = @collection.get(id)
      @collection.remove model
