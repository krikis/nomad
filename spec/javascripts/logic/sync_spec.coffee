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

    it 'collects the ids, versions and sync state of all models', ->
      @model.isSynced = -> true
      versions = @collection.versionDetails()
      expect(versions).toEqual [{id: 'some_id', version: 'vector_clock', is_new: false}]

  describe '#modelsForSync', ->
    beforeEach ->
      class TestCollection extends Backbone.Collection
      @collection = new TestCollection([], modelName: 'TestModel')
      @model = new Backbone.Model
        id: 'some_id'
      @collection.models = [@model]
      
    it 'includes all models that have patches', ->
      @model.hasPatches = -> true
      expect(@collection.modelsForSync()).toEqual([@model])

    it 'does not include models that have no patches', ->
      expect(@collection.modelsForSync()).toEqual([])
      
  describe '#dataForSync', ->
    beforeEach ->
      class TestCollection extends Backbone.Collection
      @collection = new TestCollection([], modelName: 'TestModel')
      @model = new Backbone.Model
        id: 'some_id'
        attribute: 'some_value'
      @model.version = -> 'some_version'
      @collection.models = [@model]  
      @modelsForSyncStub = sinon.stub(@collection, 'modelsForSync', => [@model])
      @markAsSyncedStub = sinon.stub(@model, 'markAsSynced')

    it 'fetches the models that have to be synced', ->
      @collection.dataForSync()
      expect(@modelsForSyncStub).toHaveBeenCalled() 
  
    it 'collects id, attributes, version and sync state', ->
      expect(@collection.dataForSync()).toEqual([
        id: 'some_id'
        attributes: 
          attribute: 'some_value'
        version: 'some_version'
        is_new: true
      ])

    it 'marks the models as synced if the markSynced option is set', ->
      versions = @collection.dataForSync(markSynced: true)
      expect(@markAsSyncedStub).toHaveBeenCalled()

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
      @dataForSyncStub = sinon.
        stub(@collection, 'dataForSync', -> [some: 'data'])

    it 'publishes all dirty models to the server', ->
      @collection.syncModels()
      expect(@message.updates).toEqual([some: 'data'])

    it 'marks all models as synced', ->
     @collection.syncModels()
     expect(@dataForSyncStub).toHaveBeenCalledWith(markSynced: true)











