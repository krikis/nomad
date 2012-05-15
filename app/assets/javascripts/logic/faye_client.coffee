@BackboneSync ||= {}
@BackboneSync.FayeClient = (->
  FayeClient = (collection, options) ->
    Faye.Logging.logLevel = if window.development then 'debug' else 'error'
    window.client ||= new Faye.Client("http://nomad.dev:9292/faye")
    # disable all non-websocket after connection to enforce websockets
    # client.disable('long-polling'); 
    # client.disable('cross-origin-long-polling'); 
    # client.disable('callback-polling');
    @client = window.client
    @collection = collection
    @channel = options.channel
    @subscribe()
    return

  FayeClient::publish = (data)->
    @client.publish "/server/" + @channel, data

  FayeClient::subscribe = ->
    @client.subscribe "/sync/" + @channel, @receive, @

  FayeClient::receive = (message) ->
    _.each message, (eventArguments, event) =>
      @[event] eventArguments

  FayeClient::update = (params) ->
    _.each params, (attributes, id) =>
      model = @collection.get(id)
      model.set attributes

  FayeClient::create = (params) ->
    _.each params, (attributes, id) =>
      model = new @collection.model(attributes)
      @collection.create model

  FayeClient::destroy = (params) ->
    _.each params, (attributes, id) =>
      model = @collection.get(id)
      @collection.remove model

  FayeClient
)()