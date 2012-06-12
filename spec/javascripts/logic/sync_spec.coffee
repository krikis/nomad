describe 'Sync', ->

  describe '#preSync', ->
    beforeEach ->
      @message = undefined
      class TestCollection extends Backbone.Collection
      @collection = new TestCollection([], modelName: 'TestModel')
      @newModelsForSyncStub = sinon.stub(@collection, '_newModelsForSync', -> ['new', 'models'])
      @modelsForSyncStub = sinon.stub(@collection, '_modelsForSync', -> ['dirty', 'models'])
      @versionDetailsStub = sinon.stub(@collection, '_versionDetails', -> ['version', 'details'])
      @publishStub = sinon.stub(@collection.fayeClient, "publish", (message) =>
        @message = message
      )

    it 'collects all new models that have to be synced', ->
      @collection.preSync()
      expect(@newModelsForSyncStub).toHaveBeenCalled()

    it 'collects version details of all new models', ->
      @collection.preSync()
      expect(@versionDetailsStub).toHaveBeenCalledWith(['new', 'models'])

    it 'collects all dirty models that have to be synced', ->
      @collection.preSync()
      expect(@modelsForSyncStub).toHaveBeenCalled()

    it 'collects version details of all dirty models', ->
      @collection.preSync()
      expect(@versionDetailsStub).toHaveBeenCalledWith(['dirty', 'models'])

    it 'publishes a list of new version details to the server', ->
      @collection.preSync()
      expect(@message.new_versions).toEqual(['version', 'details'])

    it 'publishes a list of version details to the server', ->
      @collection.preSync()
      expect(@message.versions).toEqual(['version', 'details'])

  describe '#_newModelsForSync', ->
    beforeEach ->
      class TestCollection extends Backbone.Collection
      @collection = new TestCollection([], modelName: 'TestModel')
      @model = new Backbone.Model
        id: 'some_id'
      @collection.models = [@model]

    it 'includes all models that have patches and have never been synced', ->
      @model.hasPatches = -> true
      @model.isSynced = -> false
      expect(@collection._newModelsForSync()).toEqual([@model])

    it 'does not include models that have no patches', ->
      @model.isSynced = -> false
      expect(@collection._newModelsForSync()).toEqual([])

    it 'does not include models that have been synced before', ->
      @model.hasPatches = -> true
      @model.isSynced = -> true
      expect(@collection._newModelsForSync()).toEqual([])

  describe '#_modelsForSync', ->
    beforeEach ->
      class TestCollection extends Backbone.Collection
      @collection = new TestCollection([], modelName: 'TestModel')
      @model = new Backbone.Model
        id: 'some_id'
      @collection.models = [@model]

    it 'includes all models that have patches and have been synced before', ->
      @model.hasPatches = -> true
      @model.isSynced = -> true
      expect(@collection._modelsForSync()).toEqual([@model])

    it 'does not include models that have no patches', ->
      @model.isSynced = -> true
      expect(@collection._modelsForSync()).toEqual([])

    it 'does not include models that were never synced', ->
      @model.hasPatches = -> true
      expect(@collection._modelsForSync()).toEqual([])

  describe '#_versionDetails', ->
    beforeEach ->
      class TestCollection extends Backbone.Collection
      @collection = new TestCollection([], modelName: 'TestModel')
      @model = new Backbone.Model
        id: 'some_id'
      @model.version = -> 'vector_clock'

    it 'collects the ids and versions of the models', ->
      @model.isSynced = -> true
      versions = @collection._versionDetails([@model])
      expect(versions).toEqual [{id: 'some_id', version: 'vector_clock'}]

  describe '#processUpdates', ->
    beforeEach ->
      @model = new Backbone.Model
      @rebaseStub = sinon.stub(@model, '_rebase', -> @)
      class TestCollection extends Backbone.Collection
      @collection = new TestCollection([], modelName: 'TestModel')
      @getStub = sinon.stub(@collection, 'get', => @model)
      @handleUpdateStub = sinon.stub(@model, 'handleUpdate')

    it 'fetches the model with the provided id from the collection', ->
      @collection.processUpdates
        id: {attribute: 'value'}
      expect(@getStub).toHaveBeenCalledWith('id')

    it 'lets the model handle the update', ->
      @collection.processUpdates
        id: {attribute: 'value'}
      expect(@handleUpdateStub).toHaveBeenCalledWith(attribute: 'value')

  describe '#syncModels', ->
    beforeEach ->
      class TestCollection extends Backbone.Collection
      @collection = new TestCollection([], modelName: 'TestModel')
      @message = undefined
      @publishStub = sinon.stub(@collection.fayeClient, "publish", (message) =>
        @message = message
      )
      @newModelsForSyncStub = sinon.stub(@collection, '_newModelsForSync', -> ['new', 'models'])
      @modelsForSyncStub = sinon.stub(@collection, '_modelsForSync', -> ['dirty', 'models'])
      @dataForSyncStub = sinon.
        stub(@collection, '_dataForSync', ->
          @out ||= [[new: 'data'], [dirty: 'data']]
          @out.pop()
        )

    it 'collects all dirty models', ->
      @collection.syncModels()
      expect(@modelsForSyncStub).toHaveBeenCalled()

    it 'collects the data of the dirty models', ->
      @collection.syncModels()
      expect(@dataForSyncStub).toHaveBeenCalledWith(['dirty', 'models'])

    it 'publishes all dirty model data to the server', ->
      @collection.syncModels()
      expect(@message.updates).toEqual([dirty: 'data'])

    it 'collects all new models', ->
      @collection.syncModels()
      expect(@newModelsForSyncStub).toHaveBeenCalled()

    it 'collects the data of the new models and marks them as synced', ->
      @collection.syncModels()
      expect(@dataForSyncStub).toHaveBeenCalledWith(['new', 'models'], markSynced: true)

    it 'marks new models as synced after the dirty models have been collected', ->
      @collection.syncModels()
      expect(@newModelsForSyncStub).toHaveBeenCalledAfter(@modelsForSyncStub)

    it 'publishes all new model data to the server', ->
      @collection.syncModels()
      expect(@message.creates).toEqual([new: 'data'])

 describe '#_dataForSync', ->
   beforeEach ->
     class TestCollection extends Backbone.Collection
     @collection = new TestCollection([], modelName: 'TestModel')
     @model = new Backbone.Model
       id: 'some_id'
       attribute: 'some_value'
     @model.version = -> 'some_version'
     @collection.models = [@model]
     @markAsSyncedStub = sinon.stub(@model, 'markAsSynced')

   it 'collects id, attributes and version of the models provided', ->
     expect(@collection._dataForSync([@model])).toEqual([
       id: 'some_id'
       attributes:
         attribute: 'some_value'
       version: 'some_version'
     ])

   it 'marks the models as synced if the markSynced option is set', ->
     versions = @collection._dataForSync([@model], markSynced: true)
     expect(@markAsSyncedStub).toHaveBeenCalled()











