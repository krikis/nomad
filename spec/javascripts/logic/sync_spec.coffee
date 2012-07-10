describe 'Sync', ->
  beforeEach ->
    window.localStorage.clear()
    fayeClient = 
      publish: ->
      subscribe: ->
    @clientConstructorStub = sinon.stub(Faye, 'Client', -> fayeClient)

  afterEach ->
    @clientConstructorStub.restore()
    # remove stub from window.client
    delete window.client

  describe '#preSync', ->
    beforeEach ->
      @message = undefined
      class TestCollection extends Backbone.Collection
      @collection = new TestCollection([], modelName: 'TestModel')
      @newModelsStub = sinon.stub(@collection, '_newModels', -> ['new', 'models'])
      @dirtyModelsStub = sinon.stub(@collection, '_dirtyModels', -> ['dirty', 'models'])
      @versionDetailsStub = sinon.stub(@collection, '_versionDetails')
      @versionDetailsStub.withArgs(['new', 'models']).returns(['new', 'version', 'details'])
      @versionDetailsStub.withArgs(['dirty', 'models']).returns(['version', 'details'])
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

    context 'when at least some details are present', ->
      it 'publishes a list of new version details to the server', ->
        @collection.preSync()
        expect(@message.new_versions).toEqual(['new', 'version', 'details'])

      it 'publishes a list of version details to the server', ->
        @collection.preSync()
        expect(@message.versions).toEqual(['version', 'details'])

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

  describe '#lastSynced', ->
    beforeEach ->
      class TestCollection extends Backbone.Collection
      @collection = new TestCollection([], modelName: 'TestModel')

    it 'returns the lastSynced property of the localStorage object', ->
      @collection.localStorage.lastSynced = 'timestamp'
      expect(@collection.lastSynced()).toEqual('timestamp')

  describe '#setLastSynced', ->
    beforeEach ->
      class TestCollection extends Backbone.Collection
      @collection = new TestCollection([], modelName: 'TestModel')
      @saveStorageStub = sinon.stub(@collection.localStorage, 'save')

    it 'sets the last synced timestamp on the localStorage object', ->
      @collection.setLastSynced('timestamp')
      expect(@collection.localStorage.lastSynced).toEqual('timestamp')

    it 'saves the localStorage object', ->
      @collection.setLastSynced('timestamp')
      expect(@saveStorageStub).toHaveBeenCalled()
      
    context 'when the timestamp is already up to date', ->
      beforeEach ->
        @collection.localStorage.lastSynced = 'timestamp'
      
      it 'does not save the localStorage object', ->
        @collection.setLastSynced('timestamp')
        expect(@saveStorageStub).not.toHaveBeenCalled()

  describe '#handleCreates', ->
    beforeEach ->
      class TestCollection extends Backbone.Collection
      @collection = new TestCollection([], modelName: 'TestModel')
      @getStub = sinon.stub(@collection, 'get')
      @model = new Backbone.Model
      @modelCreateStub = sinon.stub(@model, 'processCreate', ->
        @output ||= ['model_create', null]
        @output.pop()
      )
      @processCreateStub = sinon.stub(@collection, '_processCreate', -> 'process_create')

    it 'fetches the model with the provided id from the collection', ->
      @collection.handleCreates
        id: {attribute: 'value'}
      expect(@getStub).toHaveBeenCalledWith('id')

    context 'when a model can be found', ->
      beforeEach ->
        @getStub.restore()
        @getStub = sinon.stub(@collection, 'get', => @model)

      it 'lets the model handle the create when it can be found', ->
        @collection.handleCreates
          id: {attribute: 'value'}
        expect(@modelCreateStub).toHaveBeenCalledWith(attribute: 'value')

      it 'collects the compacted output of the model processCreate method', ->
        expect(@collection.handleCreates
          id: {attribute: 'value'}
          other_id: {attribute: 'other_value'}
        ).toEqual(['model_create'])

    context 'when no model can be found', ->
      it 'creates a new model', ->
        @collection.handleCreates
          id: {attribute: 'value'}
        expect(@processCreateStub).toHaveBeenCalledWith('id', attribute: 'value')

      it 'collects the output of the _processCreate method', ->
        expect(@collection.handleCreates
          id: {attribute: 'value'}
        ).toEqual(['process_create'])

  describe '#_processCreate', ->
    beforeEach ->
      class TestCollection extends Backbone.Collection
      @collection = new TestCollection([], modelName: 'TestModel')
      @model = new Backbone.Model
      @extractVersioningSpy = sinon.spy(@collection, '_extractVersioning')
      @createStub = sinon.stub(@collection, 'create', => @model)
      @setVersionStub = sinon.stub(@model, 'setVersion')
      @markAsSyncedStub = sinon.stub(@model, 'markAsSynced')
      @saveStub = sinon.stub(@model, 'save')

    it 'extracts the versioning attributes', ->
      attributes =
        attribute: 'value'
        remote_version: 'version'
      @collection._processCreate 'id', attributes
      expect(@extractVersioningSpy).toHaveBeenCalledWith(attributes)

    it 'creates a new model with the id and attributes provided', ->
      @collection._processCreate 'id',
        attribute: 'value'
        remote_version: 'version'
      expect(@createStub).toHaveBeenCalledWith
        id: 'id'
        attribute: 'value'

    it 'extracts the versioning attributes before creating the object', ->
      @collection._processCreate 'id',
        attribute: 'value'
        remote_version: 'version'
      expect(@extractVersioningSpy).toHaveBeenCalledBefore(@createStub)

    it 'sets the model version, created_at and updated_at', ->
      @collection._processCreate 'id',
        attribute: 'value'
        remote_version: 'version'
        created_at: 'created_at'
        updated_at: 'updated_at'
      expect(@setVersionStub).toHaveBeenCalledWith('version', 'created_at', 'updated_at')

    it 'marks the model as synced', ->
      @collection._processCreate 'id', {}
      expect(@markAsSyncedStub).toHaveBeenCalled()

    it 'saves the model', ->
      @collection._processCreate 'id',
        attribute: 'value'
        remote_version: 'version'
      expect(@saveStub).toHaveBeenCalled()

    it 'returns null', ->
      expect(@collection._processCreate 'id',
        attribute: 'value'
        remote_version: 'version'
      ).toBeNull()

  describe '#_extractVersioning', ->
    beforeEach ->
      class TestCollection extends Backbone.Collection
      @collection = new TestCollection([], modelName: 'TestModel')
      @attributes =
        remote_version: 'remote_version'
        created_at: 'created_at'
        updated_at: 'updated_at'

    it 'removes remote_version from the attributes', ->
      @collection._extractVersioning(@attributes)
      expect(@attributes.remote_version).toBeUndefined()

    it 'returns the remote_version', ->
      [version, b, c] = @collection._extractVersioning(@attributes)
      expect(version).toEqual('remote_version')

    it 'removes created_at from the attributes', ->
      @collection._extractVersioning(@attributes)
      expect(@attributes.created_at).toBeUndefined()

    it 'returns created_at', ->
      [a, created_at, c] = @collection._extractVersioning(@attributes)
      expect(created_at).toEqual('created_at')

    it 'removes updated_at from the attributes', ->
      @collection._extractVersioning(@attributes)
      expect(@attributes.updated_at).toBeUndefined()

    it 'returns updated_at', ->
      [a, b, updated_at] = @collection._extractVersioning(@attributes)
      expect(updated_at).toEqual('updated_at')

  describe '#handleUpdates', ->
    beforeEach ->
      @model = new Backbone.Model
      @rebaseStub = sinon.stub(@model, '_rebase', -> @)
      class TestCollection extends Backbone.Collection
      @collection = new TestCollection([], modelName: 'TestModel')
      @getStub = sinon.stub(@collection, 'get', => @model)
      @processCreateStub = sinon.stub(@collection, '_processCreate', -> 'create_output')
      @processUpdateStub = sinon.stub(@model, 'processUpdate', ->
        @output ||= ['update_output', null]
        @output.pop()
      )

    it 'fetches the model with the provided id from the collection', ->
      @collection.handleUpdates
        id: {attribute: 'value'}
      expect(@getStub).toHaveBeenCalledWith('id')

    context 'when a model can be found', ->
      it 'lets the model handle the update', ->
        @collection.handleUpdates
          id: {attribute: 'value'}
        expect(@processUpdateStub).toHaveBeenCalledWith(attribute: 'value')

      it 'collects the compacted output of the model processUpdate method', ->
        expect(@collection.handleUpdates
          id: {attribute: 'value'}
          other_id: {attribute: 'other_value'}
        ).toEqual(['update_output'])

    context 'when a model cannot be found', ->
      beforeEach ->
        @getStub.restore()
        @getStub = sinon.stub(@collection, 'get')

      it 'creates a new model', ->
        @collection.handleUpdates
          id: {attribute: 'value'}
        expect(@processCreateStub).toHaveBeenCalledWith('id', attribute: 'value')

      it 'collects the output of the _processCreate method', ->
        expect(@collection.handleUpdates
          id: {attribute: 'value'}
        ).toEqual(['create_output'])

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
      @dataForSyncStub = sinon.stub(@collection, '_dataForSync')
      @dataForSyncStub.withArgs(['new', 'models']).returns([new: 'data'])
      @dataForSyncStub.withArgs(['dirty', 'models']).returns([dirty: 'data'])

    it 'collects all dirty models', ->
      @collection.syncModels()
      expect(@dirtyModelsStub).toHaveBeenCalled()

    it 'collects the data of the dirty models', ->
      @collection.syncModels()
      expect(@dataForSyncStub).toHaveBeenCalledWith(['dirty', 'models'])

    it 'collects all new models', ->
      @collection.syncModels()
      expect(@newModelsStub).toHaveBeenCalled()

    it 'collects the data of the new models and marks them as synced', ->
      @collection.syncModels()
      expect(@dataForSyncStub).toHaveBeenCalledWith(['new', 'models'], markSynced: true)

    it 'marks new models as synced after the dirty models have been collected', ->
      @collection.syncModels()
      expect(@newModelsStub).toHaveBeenCalledAfter(@dirtyModelsStub)

    context 'when at least some data was collected', ->
      it 'publishes all dirty model data to the server', ->
        @collection.syncModels()
        expect(@message.updates).toEqual([dirty: 'data'])

      it 'publishes all new model data to the server', ->
        @collection.syncModels()
        expect(@message.creates).toEqual([new: 'data'])
        
    context 'when no data was collected', ->
      beforeEach ->
        @dataForSyncStub.restore()
        @dataForSyncStub = sinon.stub(@collection, '_dataForSync', -> [])
        
      it 'publishes an empty message to the server', ->
        @collection.syncModels()
        expect(@publishStub).toHaveBeenCalledWith(creates: [], updates: [])
        
      context 'and it is a follow up on presync', ->    
        it 'does not publish to the server', ->
          @collection.syncModels(afterPresync: true)
          expect(@publishStub).not.toHaveBeenCalled()

  describe '#_dataForSync', ->
    beforeEach ->
      class TestCollection extends Backbone.Collection
      @collection = new TestCollection([], modelName: 'TestModel')
      @model = new Backbone.Model
        id: 'some_id'
        attribute: 'some_value'
      @model.version = -> 'some_version'
      @model.createdAt = -> 'created_at'
      @model.updatedAt = -> 'updated_at'
      @collection.models = [@model]
      @markAsSyncedStub = sinon.stub(@model, 'markAsSynced')
      @updateSyncingVersionsStub = sinon.stub(@model, 'updateSyncingVersions')
      @saveStub = sinon.stub(@model, 'save')

    it 'collects all data of the models provided', ->
      expect(@collection._dataForSync([@model])).toEqual([
        id: 'some_id'
        attributes:
          attribute: 'some_value'
        version: 'some_version'
        created_at: 'created_at'
        updated_at: 'updated_at'
      ])  
        
    it 'updates the list of synced versions', ->
      versions = @collection._dataForSync([@model])
      expect(@updateSyncingVersionsStub).toHaveBeenCalled()

    it 'saves the model after updating its versioning', ->
      versions = @collection._dataForSync([@model])
      expect(@saveStub).toHaveBeenCalledAfter(@updateSyncingVersionsStub)

    context 'when the markSynced option is set', ->
      it 'marks the models as synced', ->
        versions = @collection._dataForSync([@model], markSynced: true)
        expect(@markAsSyncedStub).toHaveBeenCalled()

  describe '#syncProcessed', ->
    beforeEach ->
      class TestCollection extends Backbone.Collection
      @collection = new TestCollection([], modelName: 'TestModel')
      @message = undefined
      @dataForSyncStub = sinon.stub(@collection, '_dataForSync')
      @dataForSyncStub.withArgs(['resolved', 'models']).returns([resolved: 'data'])
      @dataForSyncStub.withArgs(['rebased', 'models']).returns([rebased: 'data'])
      @publishStub = sinon.stub(@collection.fayeClient, "publish", (message) =>
        @message = message
      )

    it 'collects data of all resolved models', ->
      @collection.syncProcessed
        creates: ['resolved', 'models']
      expect(@dataForSyncStub).toHaveBeenCalledWith(['resolved', 'models'])

    it 'collects data of all rebased models', ->
      @collection.syncProcessed
        creates: ['rebased', 'models']
      expect(@dataForSyncStub).toHaveBeenCalledWith(['rebased', 'models'])

    it 'syncs resolved and rebased models to the server', ->
      @collection.syncProcessed
        creates: ['resolved', 'models']
        updates: ['rebased', 'models']
      expect(@message).toEqual
        creates: [resolved: 'data']
        updates: [rebased: 'data']

    it 'does not publish to the server when there are no processed models', ->
      @collection.syncProcessed({})
      expect(@publishStub).not.toHaveBeenCalled()

  describe '#leave', ->
    beforeEach ->
      class TestCollection extends Backbone.Collection
      @collection = new TestCollection([], modelName: 'TestModel')
      @unsubscribeStub = sinon.stub(@collection.fayeClient, 'unsubscribe')

    it 'unsubscribes the collection from all channels', ->
      @collection.leave()
      expect(@unsubscribeStub).toHaveBeenCalledWith()

    it 'unsubscribes from a specific channel if provided', ->
      @collection.leave('some_channel')
      expect(@unsubscribeStub).toHaveBeenCalledWith('some_channel')






