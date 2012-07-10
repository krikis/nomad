Benches = @Benches ||= {}

Benches.setupPreSyncCreate = (next) ->
  # delete window.client to speed up tests
  delete window.client
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
  @dbResetSpy       = sinon.spy(@secondCollection.fayeClient, '_dbReset')  
  # clear all data stores
  @secondCollection.fayeClient._resetDb()
  window.localStorage.clear()
  @waitsFor (->
    @dbResetSpy.callCount >= 1
  ), 'second client to be in sync', 1000, (->
    # reset all spies
    @resolveSpy.reset()
    @createSpy.reset()
    @secondCreateSpy.reset()
    @secondUpdateSpy.reset()
    @dbResetSpy.reset()
    next.call(@)
  )
  return

Benches.beforePreSyncCreate = (next) ->
  @model = new @Post
    title: 'some_title'
    content: 'some_content'
  @collection.create @model
  next.call(@)
  return

Benches.preSyncCreate = (next) ->
  @collection.preSync()
  @waitsFor (->
    @createSpy.callCount >= 1 and @secondCreateSpy.callCount >= 1
  ), 'create multicast', 1000, (->
    next.call(@)
  )
  return

Benches.afterPreSyncCreate = (next) ->
  @resolveSpy.reset()
  @createSpy.reset()
  @secondCreateSpy.reset()
  @secondUpdateSpy.reset()
  next.call(@)
  return

Benches.cleanupPreSyncCreate = (next) ->
  @collection.leave()
  @secondCollection.leave()
  next.call(@)
  return
