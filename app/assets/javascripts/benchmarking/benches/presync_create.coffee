Benches = @Benches ||= {}

Benches.setupPreSyncCreate = (next) ->
  # delete window.client to speed up tests
  delete window.client
  class Post extends Backbone.Model
  class TestCollection extends Backbone.Collection
    model: Post
  @collection = new TestCollection
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
        client: new Faye.Client(FAYE_SERVER)
  @secondCollection = new SecondCollection
  @secondCreateSpy  = sinon.spy(@secondCollection.fayeClient, 'create')
  @dbResetSpy       = sinon.spy(@secondCollection.fayeClient, '_dbReset')  
  # cleanup localStorage
  @collection._cleanLocalStorage()
  @secondCollection._cleanLocalStorage()
  # clear server data store
  @secondCollection.fayeClient._resetDb()
  Util.waitsFor (->
    @dbResetSpy.callCount >= 1
  ), 'second client to be in sync', (->
    # reset all spies
    @createSpy.reset()
    @secondCreateSpy.reset()
    @dbResetSpy.reset()
    next.call(@)
  )
  return

Benches.beforePreSyncCreate = (next) ->
  @model = new @Post
    title: 'some_title'
    content: Util.benchmarkData()
  @collection.create @model
  next.call(@)
  return

Benches.preSyncCreate = (next) ->
  @collection.preSync()
  Util.waitsFor (->
    @createSpy.callCount >= 1 and @secondCreateSpy.callCount >= 1
  ), 'create multicast', (->
    next.call(@)
  )
  return

Benches.afterPreSyncCreate = (next) ->
  @createSpy.reset()
  @secondCreateSpy.reset()
  next.call(@)
  return

Benches.cleanupPreSyncCreate = (next) ->
  @collection.leave()
  @secondCollection.leave()
  # cleanup faye and localStorage for collections
  @collection._cleanup()
  @secondCollection._cleanup()
  next.call(@)
  return
