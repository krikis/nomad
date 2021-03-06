# Create a versioned model and sync it with the server using presync
describe 'presync_create', ->
  
  beforeEach ->
    # delete window.client to speed up tests
    delete window.client
    class Post extends Backbone.Model
    class TestCollection extends Backbone.Collection
      model: Post
    @collection = new TestCollection
    @resolveSpy = sinon.spy(@collection.fayeClient, 'resolve')
    @createSpy  = sinon.spy(@collection.fayeClient, 'create' )
    @Post = Post
    @pongSpy = sinon.spy(@collection.fayeClient, '_pong')
    @collection.fayeClient._ping()
    waitsFor (->
      @pongSpy.callCount >= 1
    ), 'client to be subscribed', 1000

  afterEach ->
    @collection.leave()
    @collection._cleanup()

  context 'when a model is freshly created', ->
    beforeEach ->
      @model = new @Post
        title: 'some_title'
        content: 'some_content'
      @collection.create @model

    # it 'is not synced', ->
    #   expect(@model.isSynced()).toBeFalsy()

    it 'has patches', ->
      expect(@model.hasPatches()).toBeTruthy()

    context 'and presynced', ->
      beforeEach ->
        runs ->
          @collection.preSync()
        waitsFor (->
          @resolveSpy.callCount >= 1
        ), 'resolve unicast', 1000

      # it 'receives an empty resolve unicast', ->
      #   expect(@resolveSpy).toHaveBeenCalledWith([])

      context 'and synced', ->
        beforeEach ->
          waitsFor (->
            @createSpy.callCount >= 1
          ), 'create multicast and resolve unicast', 1000
          
        # it 'receives a create multicast', ->
        #   expect(@createSpy).toHaveBeenCalled()

        # it 'is synced', ->
        #   expect(@model.isSynced()).toBeTruthy()

        it 'is forwarded to its last version', ->
          expect(@model.hasPatches()).toBeFalsy()