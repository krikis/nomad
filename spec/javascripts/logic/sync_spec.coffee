describe 'Sync', ->

  describe '#preSync', ->
    beforeEach ->
      @message = undefined
      class TestCollection extends Backbone.Collection
      @collection = new TestCollection([], modelName: 'TestModel')
      @versionDetailsStub = sinon.stub(@collection, 'versionDetails', -> ['version', 'details'])
      @publishStub = sinon.stub(@collection.fayeClient, "publish", (message) =>
        @message = message
      )

    it 'collects version details of all models in the collection', ->
      @collection.preSync()
      expect(@versionDetailsStub).toHaveBeenCalled()

    it 'publishes a list of version details to the server', ->
      @collection.preSync()
      expect(@message.versions).toEqual(['version', 'details'])

  describe '#versionDetails', ->
    beforeEach ->
      class TestCollection extends Backbone.Collection
      @collection = new TestCollection([], modelName: 'TestModel')
      @model = new Backbone.Model
        id: 'some_id'
      @model.version = -> 'vector_clock'
      @modelsForSyncStub = sinon.stub(@collection, 'modelsForSync', => [@model])

    it 'fetches the models that have to be synced', ->
      @collection.versionDetails()
      expect(@modelsForSyncStub).toHaveBeenCalled()

    it 'collects the ids and versions of all models', ->
      @model.isSynced = -> true
      versions = @collection.versionDetails()
      expect(versions).toEqual [{id: 'some_id', version: 'vector_clock'}]

    it 'sets the is_new flag for objects that were not synced yet', ->
      versions = @collection.versionDetails()
      expect(versions).toEqual [{id: 'some_id', version: 'vector_clock', is_new: true}]

  describe '#modelsForSync', ->
    beforeEach ->
      class TestCollection extends Backbone.Collection
      @collection = new TestCollection([], modelName: 'TestModel')
      @model = new Backbone.Model
        id: 'some_id'
      @markAsSyncedStub = sinon.stub(@model, 'markAsSynced')
      @collection.models = [@model]

    it 'includes all models that have patches', ->
      @model.hasPatches = -> true
      expect(@collection.modelsForSync()).toEqual([@model])

    it 'does not include models that have no patches', ->
      expect(@collection.modelsForSync()).toEqual([])

    it 'marks the models as synced if the markSynced option is set', ->
      versions = @collection.modelsForSync(markSynced: true)
      expect(@markAsSyncedStub).toHaveBeenCalled()

  describe '#processUpdates', ->
    beforeEach ->
      @model = new Backbone.Model
      @rebaseStub = sinon.stub(@model, 'rebase', -> @)
      class TestCollection extends Backbone.Collection
      @collection = new TestCollection([], modelName: 'TestModel')

    it 'rebases each model that is found in the collection', ->
      @getStub = sinon.stub @collection, 'get', (id) =>
        @model if id == 'id'
      @collection.processUpdates
        id: {attribute: 'value'}
        other_id: {attribute: 'other_value'}
      expect(@rebaseStub).toHaveBeenCalledWith(attribute: 'value')
      expect(@rebaseStub).not.
        toHaveBeenCalledWith(attribute: 'other_value')

  describe '#syncModels', ->
    beforeEach ->
      class TestCollection extends Backbone.Collection
      @collection = new TestCollection([], modelName: 'TestModel')
      @message = undefined
      @publishStub = sinon.stub(@collection.fayeClient, "publish", (message) =>
        @message = message
      )
      @modelsForSyncStub = sinon.
        stub(@collection, 'modelsForSync', -> ['dirty', 'models'])

    it 'publishes all dirty models to the server', ->
      @collection.syncModels()
      expect(@message.updates).toEqual(['dirty', 'models'])

    it 'marks all models as synced', ->
     @collection.syncModels()
     expect(@modelsForSyncStub).toHaveBeenCalledWith(markSynced: true)











