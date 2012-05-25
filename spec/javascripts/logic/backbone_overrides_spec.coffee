describe 'Overrides', ->
  
  describe 'Backbone.Collection', ->
    describe '.constructor', ->
      beforeEach ->
        @fayeClientStub = sinon.stub(BackboneSync, 'FayeClient')
        @fayeClient = sinon.stub()
        @fayeClientStub.returns(@fayeClient)
        class TestModel extends Backbone.Model
        class TestCollection extends Backbone.Collection
          model: TestModel
        @collection = new TestCollection
        
      afterEach ->
        @fayeClientStub.restore()

      it 'sets the channel to the associated model\'s constructor name', ->
        expect(@collection.channel).toEqual 'TestModel'
        
      it 'sets the channel to the channel option if provided', ->
        class TestModel extends Backbone.Model
        class TestCollection extends Backbone.Collection
          model: TestModel
        @collection = new TestCollection([], channel: 'testChannel')
        expect(@collection.channel).toEqual 'testChannel'
        
      it 'retains the channel if it was defined in the collection class', ->
        class TestModel extends Backbone.Model
        class TestCollection extends Backbone.Collection
          model: TestModel
          channel: 'predefined'
        @collection = new TestCollection([], channel: 'testChannel')
        expect(@collection.channel).toEqual 'predefined'
        
        
      it 'throws an error if no channel could be set', ->
        class TestModel extends Backbone.Model
        class TestCollection extends Backbone.Collection
        expect(-> @collection = new TestCollection()).
          toThrow 'Channel undefined: either set a valid Backbone.Model ' +
                  'or pass a channel option!'
          
        
      it 'initializes a new fayeclient for the channel', ->
        expect(@fayeClientStub).toHaveBeenCalledWith(@collection, {
          channel: @collection.channel
        })
        expect(@collection.fayeClient).toEqual @fayeClient
        