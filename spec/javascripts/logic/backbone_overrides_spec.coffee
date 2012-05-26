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
        @localStorageStub = sinon.stub(Backbone, 'LocalStorage')
        @localStorage = sinon.stub()
        @localStorageStub.returns(@localStorage)
        class TestModel extends Backbone.Model
        class TestCollection extends Backbone.Collection
          model: TestModel
        @collection = new TestCollection

      afterEach ->
        @fayeClientStub.restore()
        @localStorageStub.restore()
        
      it 'sets the url to the collection\'s constructor name', ->
        expect(@collection.url).toEqual('/test_collection')
        
      it 'preservers the url if it is already set', ->        
        class TestModel extends Backbone.Model
        class TestCollection extends Backbone.Collection
          model: TestModel
          url: 'preset_url'
        @collection = new TestCollection
        expect(@collection.url).toEqual('preset_url')

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
        
      it 'preserves the fayeclient if it is already set', ->
        class TestModel extends Backbone.Model
        class TestCollection extends Backbone.Collection
          model: TestModel
          fayeClient: {faye: 'client'}
        @collection = new TestCollection
        expect(@collection.fayeClient).toEqual({faye: 'client'})

      it 'enables localStorage for the channel', ->
        expect(@localStorageStub).toHaveBeenCalledWith(@collection.channel)
        expect(@collection.localStorage).toEqual(@localStorage)

      it 'preserves localStorage when it is already set', ->
        class TestModel extends Backbone.Model
        class TestCollection extends Backbone.Collection
          model: TestModel
          localStorage: {local: 'storage'}
        @collection = new TestCollection
        expect(@collection.localStorage).toEqual({local: 'storage'})

