Benches = @Benches ||= {}

# setup the environment for benchmarking the synchronization 
# of a conflicting update
Benches.setupSyncConflict = (next) ->
  # delete window.client to speed up benchmark setup
  delete window.client
  # setup first client
  class Post extends Backbone.Model
  class TestCollection extends Backbone.Collection
    model: Post
  @collection = new TestCollection
  # instantiate first client event spies
  @createSpy  = sinon.spy(@collection.fayeClient, 'create' )
  @updateSpy  = sinon.spy(@collection.fayeClient, 'update' )
  @Post = Post
  # setup second client
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
  # instantiate second client event spies
  @secondCreateSpy  = sinon.spy(@secondCollection.fayeClient, 'create')
  @secondUpdateSpy  = sinon.spy(@secondCollection.fayeClient, 'update')
  @dbResetSpy       = sinon.spy(@secondCollection.fayeClient, '_dbReset')  
  # cleanup browser localStorage for both clients
  @collection._cleanLocalStorage()
  @secondCollection._cleanLocalStorage()
  # clear server data store
  @secondCollection.fayeClient._resetDb()
  # wait for the second client to be successfully subscribed at the server 
  @waitsFor (->
    @dbResetSpy.callCount >= 1
  ), 'second client to be subscribed', (->
    # reset all spies
    @createSpy.reset()
    @updateSpy.reset()
    @secondCreateSpy.reset()
    @secondUpdateSpy.reset()
    @dbResetSpy.reset()
    # call the asynchronous benchmark callback
    next.call(@)
  )
  return

# setup conflicting data objects
Benches.beforeSyncConflict = (next) ->
  # create data object
  @model = new @Post
    title: 'some_title'
    content: 'some_content'
  # save it
  @collection.create @model
  # sync it to the other node in the network
  @collection.syncModels()
  @waitsFor (->
    @createSpy.callCount >= 1 and @secondCreateSpy.callCount >= 1
  ), 'create multicast', (->    
    # make sure the second client misses the first client update
    @secondCollection.fayeClient._offline()
    # update the model and sync it
    @model.save
      title: 'other_title'
    @collection.syncModels()
    @waitsFor (->
      @updateSpy.callCount >= 2 and @secondUpdateSpy.callCount >= 2
    ), 'update multicast', (->    
      @updateSpy.reset()
      @secondUpdateSpy.reset()
      # take the second client back online
      @secondCollection.fayeClient._online()
      # stub out rebase logic for cleaner measure of network latency
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

Benches.syncConflict = (next) ->  
  # synchronize conflicting update
  @secondCollection.syncModels()
  # wait for synchronization and conflict resolution completes
  @waitsFor (->
    @updateSpy.callCount >= 1 and @secondUpdateSpy.callCount >= 2
  ), 'final update multicast', (->
    next.call(@)
  )
  return

Benches.afterSyncConflict = (next) ->
  @createSpy.reset()
  @updateSpy.reset()
  @secondCreateSpy.reset()
  @secondUpdateSpy.reset()
  next.call(@)
  return

Benches.cleanupSyncConflict = (next) ->
  @collection.leave()
  @secondCollection.leave()
  # cleanup faye and localStorage for collections
  @collection._cleanup()
  @secondCollection._cleanup()
  next.call(@)
  return
  