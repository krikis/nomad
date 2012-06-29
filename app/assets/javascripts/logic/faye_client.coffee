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
    message.last_synced ||= @collection.lastSynced()
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
      
  # convenience test method for taking a client offline
  _offline: () ->
    @isOffline = true
    
  # convenience test method for bringing a client back online
  _online: () ->
    @isOffline = false
    
  receive: (message) ->
    # extract meta information
    meta = message.meta
    delete message.meta
    # process incoming data
    processed = {}
    _.map message, (eventArguments, event) =>
      @[event] eventArguments, processed
    # handle offline test mode
    return if @isOffline
    # update the collection sync state
    @collection.setLastSynced(meta.timestamp)
    # sync all dirty models if this is presync feedback
    if meta?.preSync
      @collection.syncModels(afterPresync: true)
    # sync only resolved and rebased models
    else
      @collection.syncProcessed(processed)

  resolve: (params, processed) ->
    # handle offline test mode
    return if @isOffline
    # TODO :: generate new id for conflicting models
    # TODO :: sync resolved models back to server

  create: (params, processed) ->
    # handle offline test mode
    return if @isOffline
    unless _.isEmpty(params)
      processed.creates ||= []
      resolved = @collection.handleCreates(params)
      processed.creates.merge resolved

  update: (params, processed) ->
    # handle offline test mode
    return if @isOffline
    unless _.isEmpty(params)
      processed.updates ||= []
      rebased = @collection.handleUpdates(params)
      processed.updates.merge rebased

  destroy: (params, processed) ->
    # handle offline test mode
    return if @isOffline
    # TODO :: implement deleting models
