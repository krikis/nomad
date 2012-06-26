# Create a versioned model and sync it with the server using sync
describe 'sync_create', ->
  
  beforeEach ->
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

  afterEach ->
    @collection.leave()

  context 'when a model is freshly created', ->
    beforeEach ->
      @model = new @Post
        title: 'some_title'
        content: 'some_content'
      @collection.create @model

    it 'is not synced', ->
      expect(@model.isSynced()).toBeFalsy()

    it 'has patches', ->
      expect(@model.hasPatches()).toBeTruthy()

    context 'and synced', ->
      beforeEach ->
        @collection.syncModels()
        waitsFor (->
          @createSpy.callCount > 0
        ), 'create multicast', 1000

      it 'receives a create multicast', ->
        expect(@createSpy).toHaveBeenCalled()

      it 'is synced', ->
        expect(@model.isSynced()).toBeTruthy()

      it 'is forwarded to its last version', ->
        expect(@model.hasPatches()).toBeFalsy()

      it 'receives an empty resolve unicast', ->
        expect(@resolveSpy).toHaveBeenCalledWith([])