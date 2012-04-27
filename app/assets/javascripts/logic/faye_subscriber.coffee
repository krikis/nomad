@BackboneSync = @BackboneSync or {}
BackboneSync.FayeSubscriber = (->
  FayeSubscriber = (collection, options) ->
    @collection = collection
    @client = new Faye.Client("http://nomad.dev:9292/faye")
    @channel = options.channel
    @subscribe()
    return

  FayeSubscriber::subscribe = ->
    @client.subscribe "/sync/" + @channel, _.bind(@receive, @)

  FayeSubscriber::receive = (message) ->
    $.each message, (event, eventArguments) =>
      @[event] eventArguments

  FayeSubscriber::update = (params) ->
    $.each params, (id, attributes) =>
      model = @collection.get(id)
      model.set attributes

  FayeSubscriber::create = (params) ->
    $.each params, (id, attributes) =>
      model = new @collection.model(attributes)
      @collection.create model

  FayeSubscriber::destroy = (params) ->
    $.each params, (id, attributes) =>
      model = @collection.get(id)
      @collection.remove model

  FayeSubscriber
)()