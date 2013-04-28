Benches = @Benches ||= {}

# setup the environment for benchmarking the synchronization
# of a conflicting update
Benches.setupNetwork = (next, options = {}) ->
  # delete window.client to speed up benchmark setup
  delete window.client
  # setup first client
  class Post extends Backbone.Model
    clientId: 'client'
  class TestCollection extends Backbone.Collection
    clientId: 'client'
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
        client: window.secondClient = new Faye.Client(FAYE_SERVER)
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

Benches.beforeCreate = (next, options = {}) ->
  @model = new @Post
    title: 'some_title'
    content: Util.benchmarkData(options.data)
  @collection.create @model
  next.call(@)
  return

Benches.create = (next, options = {}) ->
  if options.preSync?
    @collection.preSync()
  else
    @collection.syncModels()
  @waitsFor (->
    @createSpy.callCount >= 1 and @secondCreateSpy.callCount >= 1
  ), 'create multicast', (->
    next.call(@)
  )
  return

Benches.beforeUpdate = (next, options = {}) ->
  @model = new @Post
    title: 'some_title'
    content: 'some_content'
  @collection.create @model
  if options.preSync?
    @collection.preSync()
  else
    @collection.syncModels()
  @waitsFor (->
    @createSpy.callCount >= 1 and @secondCreateSpy.callCount >= 1
  ), 'create multicast', (->
    @updateSpy.reset()
    @secondUpdateSpy.reset()
    @model.save
      title: 'other_title'
      content: Util.benchmarkData(options.data)
    next.call(@)
  )
  return

Benches.update = (next, options = {}) ->
  if options.preSync?
    @collection.preSync()
  else
    @collection.syncModels()
  @waitsFor (->
    if options.preSync?
      @updateSpy.callCount >= 2 and @secondUpdateSpy.callCount >= 1
    else
      @updateSpy.callCount >= 1 and @secondUpdateSpy.callCount >= 1
  ), 'update multicast', (->
    next.call(@)
  )
  return

# setup conflicting data objects
Benches.beforeConflict = (next, options = {}) ->
  # create data object
  @model = new @Post
    title: 'some_title'
    content: 'some_content'
  # save it
  @collection.create @model
  # sync it to the other node in the network
  if options.preSync?
    @collection.preSync()
  else
    @collection.syncModels()
  @waitsFor (->
    @createSpy.callCount >= 1 and @secondCreateSpy.callCount >= 1
  ), 'create multicast', (->
    # make sure the second client misses the first client update
    @secondCollection.fayeClient._offline()
    # update the model and sync it
    @model.save
      content: Util.benchmarkData(options.data)
    if options.preSync?
      @collection.preSync()
    else
      @collection.syncModels()
    @waitsFor (->
      if options.preSync?
        @updateSpy.callCount >= 4 and @secondUpdateSpy.callCount >= 2
      else
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
        content: Util.benchmarkData(options.data)
      next.call(@)
    )
  )
  return

Benches.conflict = (next, options = {}) ->
  # synchronize conflicting update
  if options.preSync?
    @secondCollection.preSync()
  else
    @secondCollection.syncModels()
  # wait for synchronization and conflict resolution completes
  @waitsFor (->
    @updateSpy.callCount >= 1 and @secondUpdateSpy.callCount >= 2
  ), 'final update multicast', (->
    next.call(@)
  )
  return

Benches.afterNetwork = (next, options = {}) ->
  @createSpy.reset()
  @updateSpy.reset()
  @secondCreateSpy.reset()
  @secondUpdateSpy.reset()
  next.call(@)
  return

Benches.cleanupNetwork = (next, options = {}) ->
  @collection?.leave()
  @secondCollection?.leave()
  # cleanup faye and localStorage for collections
  @collection?._cleanup()
  @secondCollection?._cleanup()
  next.call(@)
  return
