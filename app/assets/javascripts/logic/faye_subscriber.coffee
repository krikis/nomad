@BackboneSync ||= {}
@BackboneSync.FayeSubscriber = (->
  FayeSubscriber = (collection, options) ->
    @client = new Faye.Client("http://nomad.dev:9292/faye")
    @collection = collection
    @channel = options.channel
    @subscribe()
    return

  FayeSubscriber::subscribe = ->
    @client.subscribe "/sync/" + @channel, @receive, @

  FayeSubscriber::receive = (message) ->
    _.each message, (eventArguments, event) =>
      @[event] eventArguments

  FayeSubscriber::update = (params) ->
    _.each params, (attributes, id) =>
      model = @collection.get(id)
      model.set attributes

  FayeSubscriber::create = (params) ->
    _.each params, (attributes, id) =>
      model = new @collection.model(attributes)
      @collection.create model

  FayeSubscriber::destroy = (params) ->
    _.each params, (attributes, id) =>
      model = @collection.get(id)
      @collection.remove model

  FayeSubscriber
)()