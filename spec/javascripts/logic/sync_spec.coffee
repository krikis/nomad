describe 'Sync', ->

  describe '#preSync', ->
    beforeEach ->
      @message = undefined
      class TestCollection extends Backbone.Collection
      @collection = new TestCollection([], modelName: 'TestModel')
      @newModelsStub = sinon.stub(@collection, '_newModels', -> ['new', 'models'])
      @dirtyModelsStub = sinon.stub(@collection, '_dirtyModels', -> ['dirty', 'models'])
      @versionDetailsStub = sinon.stub(@collection, '_versionDetails', -> ['version', 'details'])
      @publishStub = sinon.stub(@collection.fayeClient, "publish", (message) =>
        @message = message
      )

    it 'collects all new models that have to be synced', ->
      @collection.preSync()
      expect(@newModelsStub).toHaveBeenCalled()

    it 'collects version details of all new models', ->
      @collection.preSync()
      expect(@versionDetailsStub).toHaveBeenCalledWith(['new', 'models'])

    it 'collects all dirty models that have to be synced', ->
      @collection.preSync()
      expect(@dirtyModelsStub).toHaveBeenCalled()

    it 'collects version details of all dirty models', ->
      @collection.preSync()
      expect(@versionDetailsStub).toHaveBeenCalledWith(['dirty', 'models'])

    it 'publishes a list of new version details to the server', ->
      @collection.preSync()
      expect(@message.new_versions).toEqual(['version', 'details'])

    it 'publishes a list of version details to the server', ->
      @collection.preSync()
      expect(@message.versions).toEqual(['version', 'details'])

  describe '#_newModels', ->
    beforeEach ->
      class TestCollection extends Backbone.Collection
      @collection = new TestCollection([], modelName: 'TestModel')
      @model = new Backbone.Model
        id: 'some_id'
      @collection.models = [@model]

    it 'includes all models that have patches and have never been synced', ->
      @model.hasPatches = -> true
      @model.isSynced = -> false
      expect(@collection._newModels()).toEqual([@model])

    it 'does not include models that have no patches', ->
      @model.isSynced = -> false
      expect(@collection._newModels()).toEqual([])

    it 'does not include models that have been synced before', ->
      @model.hasPatches = -> true
      @model.isSynced = -> true
      expect(@collection._newModels()).toEqual([])

  describe '#_dirtyModels', ->
    beforeEach ->
      class TestCollection extends Backbone.Collection
      @collection = new TestCollection([], modelName: 'TestModel')
      @model = new Backbone.Model
        id: 'some_id'
      @collection.models = [@model]

    it 'includes all models that have patches and have been synced before', ->
      @model.hasPatches = -> true
      @model.isSynced = -> true
      expect(@collection._dirtyModels()).toEqual([@model])

    it 'does not include models that have no patches', ->
      @model.isSynced = -> true
      expect(@collection._dirtyModels()).toEqual([])

    it 'does not include models that were never synced', ->
      @model.hasPatches = -> true
      expect(@collection._dirtyModels()).toEqual([])

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
      
  describe '#handleCreates', ->
    beforeEach ->
      class TestCollection extends Backbone.Collection
      @collection = new TestCollection([], modelName: 'TestModel')
      @getStub = sinon.stub(@collection, 'get')
      @model = new Backbone.Model
      @modelCreateStub = sinon.stub(@model, 'processCreate')
      @processCreateStub = sinon.stub(@collection, '_processCreate')     
      
    it 'fetches the model with the provided id from the collection', ->
      @collection.handleCreates
        id: {attribute: 'value'}
      expect(@getStub).toHaveBeenCalledWith('id')

    it 'lets the model handle the create when it can be found', ->  
      @getStub.restore()
      @getStub = sinon.stub(@collection, 'get', => @model)
      @collection.handleCreates
        id: {attribute: 'value'}
      expect(@modelCreateStub).toHaveBeenCalledWith(attribute: 'value')
      
    it 'creates a new model', ->
      @collection.handleCreates
        id: {attribute: 'value'}
      expect(@processCreateStub).toHaveBeenCalledWith('id', attribute: 'value')
      
  describe '#_processCreate', ->
    beforeEach ->
      class TestCollection extends Backbone.Collection
      @collection = new TestCollection([], modelName: 'TestModel')
      @model = new Backbone.Model
      @createStub = sinon.stub(@collection, 'create', => @model)
      @setVersionStub = sinon.stub(@model, 'setVersion')
      @saveStub = sinon.stub(@model, 'save')
      
    it 'creates a new model with the id and attributes provided 
        except remote_version', ->
      @collection._processCreate 'id',
        attribute: 'value'
        remote_version: 'version'
      expect(@createStub).toHaveBeenCalledWith
        id: 'id'
        attribute: 'value'
        
    it 'sets the model\'s version to the remote_version', ->
      @collection._processCreate 'id',
        attribute: 'value'
        remote_version: 'version'
      expect(@setVersionStub).toHaveBeenCalledWith('version')
      
    it 'saves the model', ->
      @collection._processCreate 'id',
        attribute: 'value'
        remote_version: 'version'
      expect(@saveStub).toHaveBeenCalled()
      

  describe '#handleUpdates', ->
    beforeEach ->
      @model = new Backbone.Model
      @rebaseStub = sinon.stub(@model, '_rebase', -> @)
      class TestCollection extends Backbone.Collection
      @collection = new TestCollection([], modelName: 'TestModel')
      @getStub = sinon.stub(@collection, 'get', => @model)
      @processCreateStub = sinon.stub(@collection, '_processCreate')
      @processUpdateStub = sinon.stub(@model, 'processUpdate')

    it 'fetches the model with the provided id from the collection', ->
      @collection.handleUpdates
        id: {attribute: 'value'}
      expect(@getStub).toHaveBeenCalledWith('id')

    it 'lets the model handle the update when it can be found', ->
      @collection.handleUpdates
        id: {attribute: 'value'}
      expect(@processUpdateStub).toHaveBeenCalledWith(attribute: 'value')
      
    it 'creates a new model when it can not be found', ->
      @getStub.restore()
      @getStub = sinon.stub(@collection, 'get')
      @collection.handleUpdates
        id: {attribute: 'value'}
      expect(@processCreateStub).toHaveBeenCalledWith('id', attribute: 'value')
      

  describe '#syncModels', ->
    beforeEach ->
      class TestCollection extends Backbone.Collection
      @collection = new TestCollection([], modelName: 'TestModel')
      @message = undefined
      @publishStub = sinon.stub(@collection.fayeClient, "publish", (message) =>
        @message = message
      )
      @newModelsStub = sinon.stub(@collection, '_newModels', -> ['new', 'models'])
      @dirtyModelsStub = sinon.stub(@collection, '_dirtyModels', -> ['dirty', 'models'])
      @dataForSyncStub = sinon.
        stub(@collection, '_dataForSync', ->
          @out ||= [[new: 'data'], [dirty: 'data']]
          @out.pop()
        )

    it 'collects all dirty models', ->
      @collection.syncModels()
      expect(@dirtyModelsStub).toHaveBeenCalled()

    it 'collects the data of the dirty models', ->
      @collection.syncModels()
      expect(@dataForSyncStub).toHaveBeenCalledWith(['dirty', 'models'])

    it 'publishes all dirty model data to the server', ->
      @collection.syncModels()
      expect(@message.updates).toEqual([dirty: 'data'])

    it 'collects all new models', ->
      @collection.syncModels()
      expect(@newModelsStub).toHaveBeenCalled()

    it 'collects the data of the new models and marks them as synced', ->
      @collection.syncModels()
      expect(@dataForSyncStub).toHaveBeenCalledWith(['new', 'models'], markSynced: true)

    it 'marks new models as synced after the dirty models have been collected', ->
      @collection.syncModels()
      expect(@newModelsStub).toHaveBeenCalledAfter(@dirtyModelsStub)

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











