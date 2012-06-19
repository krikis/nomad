@BackboneSync ||= {}

class @BackboneSync.FayeClient
  constructor: (collection, options = {}) ->
    @client = options.client
    @modelName = options.modelName
    @clientId = options.clientId
    unless @client?
      window.client ||= new Faye.Client("http://nomad.dev:9292/faye")
      @client = window.client
    @collection = collection
    @modelName ||= collection.modelName
    @clientId ||= collection.clientId
    @subscriptions = []
    @subscribe()
    Faye.Logging.logLevel = if window.development then 'info' else 'error'
    # disable all non-websocket after connection to enforce websockets
    # client.disable('long-polling');
    # client.disable('cross-origin-long-polling');
    # client.disable('callback-polling');

  publish: (message)->
    message.client_id ||= @clientId
    message.model_name ||= @modelName
    @client.publish "/server/" + @modelName, message

  subscribe: ->
    global_channel = "/sync/#{@modelName}"
    private_channel = "/sync/#{@modelName}/#{@clientId}"
    @client.subscribe global_channel, @receive, @
    @subscriptions.push(global_channel)
    @client.subscribe private_channel, @receive, @
    @subscriptions.push(private_channel)
    
  unsubscribe: (channel) ->
    subscriptions = [channel] if channel?
    subscriptions ||= _.clone @subscriptions
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
