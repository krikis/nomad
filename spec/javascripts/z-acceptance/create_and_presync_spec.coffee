# Create a versioned model and sync it with the server using presync
scenario 'create_and_presync', ->

  describe 'VersionedModel', ->
    beforeEach ->
      # delete window.client instead of waiting for unsubscribes to get acknowledged
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

    context 'when it is freshly created', ->
      beforeEach ->
        @model = new @Post
          title: 'some_title'
          content: 'some_content'
        @collection.create @model

      it 'is not synced', ->
        expect(@model.isSynced()).toBeFalsy()

      it 'has patches', ->
        expect(@model.hasPatches()).toBeTruthy()

      context 'and presynced', ->
        beforeEach ->
          runs ->
            @collection.preSync()
          waitsFor (->
            @resolveSpy.callCount > 0
          ), 'resolve unicast', 1000

        it 'receives a resolve unicast', ->
          expect(@resolveSpy).toHaveBeenCalledWith([])

        context 'and synced', ->
          beforeEach ->
            waitsFor (->
              @createSpy.callCount > 0 and @resolveSpy.callCount > 1
            ), 'create multicast and resolve unicast', 1000
            
          it 'receives a create multicast', ->
            expect(@createSpy).toHaveBeenCalled()

          it 'is synced', ->
            expect(@model.isSynced()).toBeTruthy()

          it 'is forwarded to its last version', ->
            expect(@model.hasPatches()).toBeFalsy()

          it 'receives a resolve unicast', ->
            expect(@resolveSpy).toHaveBeenCalledWith([])