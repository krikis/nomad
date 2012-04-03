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
    self = @
    $.each message, (event, eventArguments) ->
      self[event] eventArguments

  FayeSubscriber::update = (params) ->
    self = @
    $.each params, (id, attributes) ->
      model = self.collection.get(id)
      model.set attributes

  FayeSubscriber::create = (params) ->
    self = @
    $.each params, (id, attributes) ->
      model = new self.collection.model(attributes)
      self.collection.create model

  FayeSubscriber::destroy = (params) ->
    self = @
    $.each params, (id, attributes) ->
      model = self.collection.get(id)
      self.collection.remove model

  FayeSubscriber
)()