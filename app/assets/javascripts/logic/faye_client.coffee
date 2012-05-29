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
    @channel = options.channel
    @subscribe()

  publish: (data)->
    @client.publish "/server/" + @channel, data

  subscribe: ->
    @client.subscribe "/sync/#{@channel}", @receive, @
    @client.subscribe "/sync/#{@channel}/#{Nomad.clientId}", @receive, @

  receive: (message) ->
    _.each message, (eventArguments, event) =>
      @[event] eventArguments

  update: (params) ->
    @collection.processUpdates(params)

  create: (params) ->
    _.each params, (attributes, id) =>
      model = new @collection.model(attributes)
      @collection.create model

  destroy: (params) ->
    _.each params, (attributes, id) =>
      model = @collection.get(id)
      @collection.remove model
