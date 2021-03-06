# Resolve a conflict detected during presync
describe 'presync_conflict', ->

  describe 'VersionedModel', ->
    beforeEach ->
      # delete window.client to speed up tests
      delete window.client
      # create first client
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
        # create model on first client
        @model = new Post
          title: 'some_title'
          content: 'some_content'
        @collection.create @model
        @collection.preSync()
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

    context 'when a client updates a model and presyncs it', ->
      beforeEach ->
        # update the model and sync it
        @model.save
          title: 'other_title'
        @collection.preSync()
        waitsFor (->
          @updateSpy.callCount >= 4 and @secondUpdateSpy.callCount >= 2
        ), 'update multicast', 1000

      it 'is not received by an offline client', ->
        expect(_.first(@secondCollection.models).get('title')).toEqual('some_title')

      context 'and another client updates the same model and presyncs it', ->
        beforeEach ->
          # take the second client back online
          @secondCollection.fayeClient._online()
          # create a conflicting update and sync it
          _.first(@secondCollection.models).save
            content: 'other_content'
          @secondCollection.preSync()
          waitsFor (->
            @updateSpy.callCount >= 5 and @secondUpdateSpy.callCount >= 4
          ), 'update unicast', 1000

        # it 'reflects the first update', ->
        #   expect(@model.get('title')).toEqual('other_title')

        it 'reflects the second update', ->
          expect(@model.get('content')).toEqual('other_content')
          
        # it 'contains no patches for the second update', ->
        #   expect(@model.hasPatches()).toBeFalsy()

