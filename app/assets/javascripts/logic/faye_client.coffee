@BackboneSync ||= {}

# @FAYE_SERVER = 'http://195.240.7.166:9292/faye'
# @FAYE_SERVER = 'http://192.168.1.35:9292/faye'
# @FAYE_SERVER = 'http://nomad.dev:9292/faye'
@FAYE_SERVER = 'http://129.125.147.34:9292/faye'

class @BackboneSync.FayeClient
  constructor: (collection, options = {}) ->
    @client = options.client
    @modelName = options.modelName
    @clientId = options.clientId
    unless @client?
      window.client ||= new Faye.Client(FAYE_SERVER)
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

  publish: (message) ->
    # handle offline test mode
    return if @isOffline
    message.client_id ||= @clientId
    message.model_name ||= @modelName
    message.last_synced ||= @collection.lastSynced()
    message.sync_sessions ||= @collection.syncSessions()
    @client.publish "/server/" + @modelName, message

  # subscribe collection to synchronization channels
  subscribe: ->
    # subscribe to multicast channel
    global_channel = "/sync/#{@modelName}"
    @client.subscribe global_channel, @receive, @
    @subscriptions.push(global_channel)
    # subscribe to unicast channel
    private_channel = "/sync/#{@modelName}/#{@clientId}"
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

  # convenience test method for resetting server db
  _resetDb: () ->
    @publish
      reset_db: true
      
  # convenience method testing connectivity
  _ping: () ->
    @publish
      ping: true

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
    @collection.setLastSynced(meta)
    if meta.client == @clientId
      # sync all dirty models if this is presync feedback
      if meta.preSync
        @collection.syncModels(afterPresync: true)
      # sync only resolved and rebased models
      else
        @collection.syncProcessed(processed)

  _dbReset: ->
    # console.log 'The server database was successfully reset!'
    
  _pong: ->
    # console.log 'pong received'

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
