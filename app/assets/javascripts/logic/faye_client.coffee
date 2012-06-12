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
    # extract meta information
    meta = message.meta
    delete message.meta
    # process incoming data
    _.each message, (eventArguments, event) =>
      @[event] eventArguments
    # do the actual sync if this was presync feedback
    @collection.syncModels() if meta?.preSync
    # TODO resync resolved and rebased if this was no presync feedback
  
  resolve: (params) ->
    # TODO generate new id for conflicting models

  create: (params) ->
    unless _.isEmpty(params)
      @collection.handleCreates(params)
  
  update: (params) ->
    unless _.isEmpty(params)
      @collection.handleUpdates(params)

  destroy: (params) ->
    _.each params, (attributes, id) =>
      model = @collection.get(id)
      @collection.remove model
