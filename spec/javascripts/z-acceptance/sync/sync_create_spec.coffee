# Create a versioned model and sync it with the server using sync
describe 'sync_create', ->

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
    waitsFor (->
      @secondCollection.fayeClient.client.getState() == 'CONNECTED'
    ), 'second client to connect', 1000

  afterEach ->
    @collection.leave()
    @secondCollection.leave()
    @collection._cleanup()
    @secondCollection._cleanup()

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

    context 'and synced', ->
      beforeEach ->
        @collection.syncModels()
        waitsFor (->
          @createSpy.callCount >= 1 and @secondCreateSpy.callCount >= 1
        ), 'create multicast', 1000

      # it 'receives a create multicast', ->
      #   expect(@createSpy).toHaveBeenCalled()

      # it 'is synced', ->
      #   expect(@model.isSynced()).toBeTruthy()

      it 'is forwarded to its last version', ->
        expect(@model.hasPatches()).toBeFalsy()
        
      it 'exists on another client', ->
        expect(_.first(@secondCollection.models).toJSON())
          .toEqual(@model.toJSON())
          
      # it 'has no patches on another client', ->
      #   expect(_.first(@secondCollection.models).hasPatches())
      #     .toBeFalsy()
          
          
        




