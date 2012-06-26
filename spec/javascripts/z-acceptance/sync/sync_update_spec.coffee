# Update a versioned model and sync it with the server using sync
describe 'sync_update', ->

  beforeEach ->
    # delete window.client to speed up tests
    delete window.client
    window.localStorage.clear()
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
          client: new Faye.Client("http://nomad.dev:9292/faye")
    @secondCollection = new SecondCollection
    @secondCreateSpy  = sinon.spy(@secondCollection.fayeClient, 'create')
    @secondUpdateSpy  = sinon.spy(@secondCollection.fayeClient, 'update')
    waitsFor (->
      @secondCollection.fayeClient.client.getState() == 'CONNECTED'
    ), 'second client connected', 1000
    runs ->
      @model = new Post
        title: 'some_title'
        content: 'some_content'
      @collection.create @model
      @collection.syncModels()
    waitsFor (->
      @createSpy.callCount > 0
    ), 'create multicast', 1000

  afterEach ->
    @collection.leave()
    @secondCollection.leave()
    
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
          @updateSpy.callCount > 3 and @secondUpdateSpy.callCount > 1
        ), 'update multicast', 1000
        
      # it 'receives an update multicast', ->
      #   expect(@updateSpy).toHaveBeenCalled()

      it 'is forwarded to its last version', ->
        expect(@model.hasPatches()).toBeFalsy()
        
      # it 'received an empty update unicast', ->
      #   expect(@updateSpy).toHaveBeenCalledWith({})
        
      it 'is updated on another client', ->
        expect(_.first(@secondCollection.models).toJSON())
          .toEqual(@model.toJSON())
          
          
      
        
      

