Benches = @Benches ||= {}

Benches.setupPreSyncConflict = (next) -> 
  # delete window.client to speed up tests
  delete window.client
  class Post extends Backbone.Model
    clientId: 'client'
  class TestCollection extends Backbone.Collection
    clientId: 'client'
    model: Post
  @collection = new TestCollection
  @createSpy  = sinon.spy(@collection.fayeClient, 'create' )
  @updateSpy  = sinon.spy(@collection.fayeClient, 'update' )
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
        client: window.secondClient = new Faye.Client(FAYE_SERVER)
  @secondCollection = new SecondCollection
  @secondCreateSpy  = sinon.spy(@secondCollection.fayeClient, 'create')
  @secondUpdateSpy  = sinon.spy(@secondCollection.fayeClient, 'update')
  @dbResetSpy       = sinon.spy(@secondCollection.fayeClient, '_dbReset')  
  # cleanup localStorage
  @collection._cleanLocalStorage()
  @secondCollection._cleanLocalStorage()
  # clear server data store
  @secondCollection.fayeClient._resetDb()
  @waitsFor (->
    @dbResetSpy.callCount >= 1
  ), 'second client to be in sync', (->
    # reset all spies
    @createSpy.reset()
    @updateSpy.reset()
    @secondCreateSpy.reset()
    @secondUpdateSpy.reset()
    @dbResetSpy.reset()
    next.call(@)
  )
  return

Benches.beforePreSyncConflict = (next) ->
  @model = new @Post
    title: 'some_title'
    content: 'some_content'
  @collection.create @model
  @collection.preSync()
  @waitsFor (->
    @createSpy.callCount >= 1 and @secondCreateSpy.callCount >= 1
  ), 'create multicast', (->    
    # make sure the second client misses the first client update
    @secondCollection.fayeClient._offline()
    # update the model and sync it
    @model.save
      content: Util.benchmarkData(@benchData)
    @collection.preSync()
    @waitsFor (->
      @updateSpy.callCount >= 4 and @secondUpdateSpy.callCount >= 2
    ), 'update multicast', (->    
      @updateSpy.reset()
      @secondUpdateSpy.reset()
      # take the second client back online
      @secondCollection.fayeClient._online()
      # stub out rebase logic to speed up bench
      sinon.stub _.last(@secondCollection.models), '_rebase', (attributes) ->
        [version, created_at, updated_at] =
          @_extractVersioning(attributes)
        @_updateVersionTo(version, updated_at)
        @
      # create a conflicting update
      _.last(@secondCollection.models).save
        content: Util.benchmarkData(@benchData)
      next.call(@)
    )
  )
  return

Benches.preSyncConflict = (next) ->  
  @secondCollection.preSync()
  @waitsFor (->
    @updateSpy.callCount >= 1 and @secondUpdateSpy.callCount >= 2
  ), 'final update multicast', (->
    next.call(@)
  )
  return

Benches.afterPreSyncConflict = (next) ->
  @createSpy.reset()
  @updateSpy.reset()
  @secondCreateSpy.reset()
  @secondUpdateSpy.reset()
  next.call(@)
  return

Benches.cleanupPreSyncConflict = (next) ->
  @collection?.leave()
  @secondCollection?.leave()
  # cleanup faye and localStorage for collections
  @collection?._cleanup()
  @secondCollection?._cleanup()
  next.call(@)
  return
  