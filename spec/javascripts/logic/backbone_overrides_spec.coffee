describe 'Overrides', ->
  
  describe 'Backbone.Model', ->
    beforeEach ->
      window.localStorage.clear()
      @server = sinon.fakeServer.create()

    afterEach ->
      @server.restore()
    
    describe '.constructor', ->
      beforeEach ->
        class TestModel extends Backbone.Model
        # stub before creation because of callback binding
        @addPatchStub = sinon.stub Backbone.Model::, "addPatch"
        @model = new TestModel Factory.build("answer")

      afterEach ->
        @addPatchStub.restore()
      
      it 'binds #addPatch to the model change event', ->
        @model.trigger 'change'
        expect(@addPatchStub).toHaveBeenCalled()
        
  describe 'Backbone.Collection', ->
    describe '.constructor', ->
      beforeEach ->
        @fayeClientStub = sinon.stub(BackboneSync, 'FayeClient')
        @fayeClient = sinon.stub()
        @fayeClientStub.returns(@fayeClient)
        class TestCollection extends Backbone.Collection
        @collection = new TestCollection
        
      afterEach ->
        @fayeClientStub.restore()

      it 'sets the channel attribute to the constructor name', ->
        expect(@collection.channel).toEqual 'testcollection'
        
      it 'initializes a new fayeclient for the channel', ->
        expect(@fayeClientStub).toHaveBeenCalledWith(@collection, {
          channel: @collection.channel
        })
        expect(@collection.fayeClient).toEqual @fayeClient
        