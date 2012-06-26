# Update a versioned model and sync it with the server using presync
scenario 'update_and_presync', ->

  describe 'VersionedModel', ->
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
      @model = new Post
        title: 'some_title'
        content: 'some_content'
      @collection.create @model
      @collection.preSync()
      waitsFor (->
        @createSpy.callCount > 0
      ), 'create multicast', 1000

    afterEach ->
      @collection.leave()
      
    context 'when it is updated', ->
      beforeEach ->
        @model.save
          title: 'other_title'
          content: 'other_content'
          
      it 'has patches', ->    
        expect(@model.hasPatches()).toBeTruthy()
        
      context 'and presynced', ->
        beforeEach ->
          @collection.preSync()
          waitsFor (->
            @updateSpy.callCount > 3
          ), 'update unicast', 1000
          
        it 'receives an update unicast', ->
          expect(@updateSpy).toHaveBeenCalledWith({})

        context 'and synced', ->
          beforeEach ->
            waitsFor (->
              @updateSpy.callCount > 5
            ), 'update multicast', 1000
            
          it 'receives an update multicast', ->
            expect(@updateSpy).toHaveBeenCalled()

          it 'is forwarded to its last version', ->
            expect(@model.hasPatches()).toBeFalsy()
            
          it 'received an update unicast', ->
            expect(@updateSpy).toHaveBeenCalledWith({})
            
          
      
        
      

