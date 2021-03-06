# Update a versioned model and sync it with the server using sync
describe 'sync_update', ->

  beforeEach ->
    # delete window.client to speed up tests
    delete window.client
    class Post extends Backbone.Model
    class TestCollection extends Backbone.Collection
      model: Post
    @collection = new TestCollection
    @createSpy  = sinon.spy(@collection.fayeClient, 'create' )
    @updateSpy  = sinon.spy(@collection.fayeClient, 'update' )
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
    @secondUpdateSpy  = sinon.spy(@secondCollection.fayeClient, 'update')
    @pongSpy = sinon.spy(@secondCollection.fayeClient, '_pong')
    @secondCollection.fayeClient._ping()
    waitsFor (->
      @pongSpy.callCount >= 1
    ), 'second client to be subscribed', 1000
    runs ->
      @model = new Post
        title: 'some_title'
        content: 'some_content'
      @collection.create @model
      @collection.syncModels()
    waitsFor (->
      @createSpy.callCount >= 1
    ), 'create multicast', 1000

  afterEach ->
    @collection.leave()
    @secondCollection.leave()
    @collection._cleanup()
    @secondCollection._cleanup()
    
  context 'when a model is updated', ->
    beforeEach ->
      @model.save
        title: 'other_title'
        content: 'other_content'
        
    it 'has patches', ->    
      expect(@model.hasPatches()).toBeTruthy()

    context 'and synced', ->
      beforeEach ->
        @collection.syncModels()
        waitsFor (->
          @updateSpy.callCount >= 2 and @secondUpdateSpy.callCount >= 2
        ), 'update multicast', 1000
        
      # it 'receives an update multicast', ->
      #   expect(@updateSpy).toHaveBeenCalled()

      it 'is forwarded to its last version', ->
        expect(@model.hasPatches()).toBeFalsy()
        
      it 'is updated on another client', ->
        expect(_.first(@secondCollection.models).toJSON())
          .toEqual(@model.toJSON())
          
      # it 'has no patches on another client', ->
      #   expect(_.first(@secondCollection.models).hasPatches())
      #     .toBeFalsy()
          
          
      
        
      

