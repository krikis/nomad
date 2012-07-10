Benches = @Benches ||= {}

Benches.setupSyncCreate = (next) ->
  # delete window.client to speed up tests
  delete window.client
  window.localStorage.clear()
  class Post extends Backbone.Model
  class TestCollection extends Backbone.Collection
    model: Post
  @collection = new TestCollection
  @resolveSpy = sinon.spy(@collection.fayeClient, 'resolve')
  @createSpy  = sinon.spy(@collection.fayeClient, 'create' )
  @Post = Post
  # create second client
  class SecondPost extends Backbone.Model
    clientId: 'second_client'
  class SecondCollection extends Backbone.Collection
    model: SecondPost
    clientId: 'second_client'
    fayeClient: 'faye_client'
    initialize: ->
      @fayeClient = new BackboneSync.FayeClient @,
        modelName: 'Post'
        client: new Faye.Client("http://nomad.dev:9292/faye")
  @secondCollection = new SecondCollection
  @secondCreateSpy  = sinon.spy(@secondCollection.fayeClient, 'create')
  @secondUpdateSpy  = sinon.spy(@secondCollection.fayeClient, 'update')
  model = new SecondPost
    title: 'some_title'
    content: 'some_content'
  @secondCollection.create model
  @secondCollection.syncModels()
  @waitsFor (->
    @secondCreateSpy.callCount >= 1
  ), 'second client to be in sync', 1000, (->
    @resolveSpy.reset()
    @createSpy.reset()
    @secondCreateSpy.reset()
    @secondUpdateSpy.reset()
    next.call(@)
  )
  return

Benches.beforeSyncCreate = (next) ->
  @model = new @Post
    title: 'some_title'
    content: 'some_content'
  @collection.create @model
  next.call(@)
  return

Benches.syncCreate = (next) ->
  @collection.syncModels()
  @waitsFor (->
    @createSpy.callCount >= 1 and @secondCreateSpy.callCount >= 1
  ), 'create multicast', 1000, (->
    next.call(@)
  )
  return

Benches.afterSyncCreate = (next) ->
  @resolveSpy.reset()
  @createSpy.reset()
  @secondCreateSpy.reset()
  @secondUpdateSpy.reset()
  next.call(@)
  return

Benches.cleanupSyncCreate = (next) ->
  @collection.leave()
  @secondCollection.leave()
  next.call(@)
  return
