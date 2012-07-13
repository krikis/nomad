Benches = @Benches ||= {}

Benches.setupSyncConflict = (next) ->
  # delete window.client to speed up tests
  delete window.client
  class Post extends Backbone.Model
  class TestCollection extends Backbone.Collection
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
        client: new Faye.Client("http://nomad.dev:9292/faye")
  @secondCollection = new SecondCollection
  @secondCreateSpy  = sinon.spy(@secondCollection.fayeClient, 'create')
  @secondUpdateSpy  = sinon.spy(@secondCollection.fayeClient, 'update')
  @dbResetSpy       = sinon.spy(@secondCollection.fayeClient, '_dbReset')  
  # clear all data stores
  @secondCollection.fayeClient._resetDb()
  @waitsFor (->
    @dbResetSpy.callCount >= 1
  ), 'second client to be in sync', 1000, (->
    # reset all spies
    @createSpy.reset()
    @updateSpy.reset()
    @secondCreateSpy.reset()
    @secondUpdateSpy.reset()
    @dbResetSpy.reset()
    next.call(@)
  )
  return

Benches.beforeSyncConflict = (next) ->
  @model = new @Post
    title: 'some_title'
    content: 'some_content'
  @collection.create @model
  @collection.syncModels()
  @waitsFor (->
    @createSpy.callCount >= 1 and @secondCreateSpy.callCount >= 1
  ), 'create multicast', 1000, (->    
    # make sure the second client misses the first client update
    @secondCollection.fayeClient._offline()
    # update the model and sync it
    @model.save
      title: 'other_title'
    @collection.syncModels()
    @waitsFor (->
      @updateSpy.callCount >= 2 and @secondUpdateSpy.callCount >= 2
    ), 'update multicast', 1000, (->    
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
        content: @benchmarkData()
      next.call(@)
    )
  )
  return

Benches.syncConflict = (next) ->  
  @secondCollection.syncModels()
  @waitsFor (->
    @updateSpy.callCount >= 1 and @secondUpdateSpy.callCount >= 2
  ), 'final update multicast', 1000, (->
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
  # cleanup localStorage for collections
  @collection._cleanup()
  @secondCollection._cleanup()
  next.call(@)
  return
  