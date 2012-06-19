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
    @subscriptions = []
    @subscribe()

  publish: (message)->
    message.client_id ||= Nomad.clientId
    message.model_name ||= @modelName
    @client.publish "/server/" + @modelName, message

  subscribe: ->
    global_channel = "/sync/#{@modelName}"
    private_channel = "/sync/#{@modelName}/#{Nomad.clientId}"
    @client.subscribe global_channel, @receive, @
    @subscriptions.push(global_channel)
    @client.subscribe private_channel, @receive, @
    @subscriptions.push(private_channel)
    
  unsubscribe: (channel) ->
    subscriptions = [channel] if channel?
    subscriptions ||= @subscriptions
    _.each subscriptions, (subscription) =>
      @client.unsubscribe subscription
      @subscriptions.delete(subscription)

  receive: (message) ->
    # extract meta information
    meta = message.meta
    delete message.meta
    # process incoming data
    processed = {}
    _.map message, (eventArguments, event) =>
      @[event] eventArguments, processed
    # sync all dirty models if this is presync feedback
    if meta?.preSync
      @collection.syncModels()
    # sync only resolved and rebased models
    else
      @collection.syncProcessed(processed)

  resolve: (params, processed) ->
    # TODO :: generate new id for conflicting models
    # TODO :: sync resolved models back to server

  create: (params, processed) ->
    unless _.isEmpty(params)
      processed.creates ||= []
      resolved = @collection.handleCreates(params)
      processed.creates.merge resolved

  update: (params, processed) ->
    unless _.isEmpty(params)
      processed.updates ||= []
      rebased = @collection.handleUpdates(params)
      processed.updates.merge rebased

  destroy: (params, processed) ->
    # TODO :: implement deleting models
