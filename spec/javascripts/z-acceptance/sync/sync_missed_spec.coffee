# Receive missed updates
describe 'sync_missed', ->

  beforeEach ->
    # delete window.client to speed up tests
    delete window.client
    # create first client
    class Post extends Backbone.Model
    class TestCollection extends Backbone.Collection
      model: Post
    @collection = new TestCollection
    @createSpy  = sinon.spy(@collection.fayeClient, 'create')
    @updateSpy  = sinon.spy(@collection.fayeClient, 'update')
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
    waitsFor (->
      @secondCollection.fayeClient.client.getState() == 'CONNECTED'
    ), 'second client to connect', 1000
    runs ->
      # create model on first client
      @model = new Post
        title: 'some_title'
        content: 'some_content'
      @collection.create @model
      @collection.syncModels()
    # wait until model is successfully synced to all clients
    waitsFor (->
      @createSpy.callCount >= 1 and @secondCreateSpy.callCount >= 1
    ), 'create multicast', 1000
    runs ->
      # make sure the second client misses the first client update
      @secondCollection.fayeClient._offline()

  afterEach ->
    @collection.leave()
    @secondCollection.leave()
    @collection._cleanup()
    @secondCollection._cleanup()

  context 'when a client updates a model and syncs it', ->
    beforeEach ->
      # update the model and sync it
      @model.save
        title: 'other_title'
      @collection.syncModels()
      waitsFor (->
        @updateSpy.callCount >= 2 and @secondUpdateSpy.callCount >= 2
      ), 'update unicast', 1000

    it 'is not received by an offline client', ->
      expect(_.first(@secondCollection.models).get('title')).
        toEqual('some_title')

    context 'and another client syncs with the server', ->
      beforeEach ->
        # take the second client back online
        @secondCollection.fayeClient._online()
        # sync with the server
        @secondCollection.syncModels()
        waitsFor (->
          @secondUpdateSpy.callCount >= 3
        ), 'update unicast', 1000

      it 'is eventually received by another client', ->
        expect(_.first(@secondCollection.models).get('title')).
          toEqual('other_title')

