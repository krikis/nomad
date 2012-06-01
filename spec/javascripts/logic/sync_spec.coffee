describe 'Sync', ->

  describe '#preSync', ->
    beforeEach ->
      @message = undefined
      class TestCollection extends Backbone.Collection
      @collection = new TestCollection([], modelName: 'TestModel')
      @publishStub = sinon.stub(@collection.fayeClient, "publish", (message) =>
        @message = message
      )

    context 'when there are fresh models', ->
      beforeEach ->
        @freshModelsStub = sinon.
          stub(@collection, 'freshModels', -> ['new', 'models'])

      it 'collects all models that were never synced', ->
        @collection.preSync()
        expect(@freshModelsStub).toHaveBeenCalled()

      it 'marks all unsynced models as synced', ->
        @collection.preSync()
        expect(@freshModelsStub).toHaveBeenCalledWith(markAsSynced: true)

      it 'publishes all fresh models to the server', ->
        @collection.preSync()
        expect(@message.creates).toEqual(['new', 'models'])

    context 'when there are changed models', ->
      beforeEach ->
        @changedModelsStub = sinon.
          stub(@collection, 'changedModels', => ['changed', 'models'])

      it 'collects all changed models', ->
        @collection.preSync()
        expect(@changedModelsStub).toHaveBeenCalled()

      it 'publishes a list of changed models to the server', ->
        @collection.preSync()
        expect(@message.changes).toEqual(['changed', 'models'])

    context 'when there are no fresh or changed models', ->
      beforeEach ->
        @freshModelsStub = sinon.stub(@collection, 'freshModels', -> [])
        @changedModelsStub = sinon.stub(@collection, 'changedModels', => [])

      it 'does not publish to the server', ->
        @collection.preSync()
        expect(@publishStub).not.toHaveBeenCalled()

  describe '#freshModels', ->
    beforeEach ->
      class TestCollection extends Backbone.Collection
      @collection = new TestCollection([], modelName: 'TestModel')
      @fresh_model = new Backbone.Model
        id: 'some_id'
        attribute: 'some_value'
      @fresh_model.version = -> 'some_hash'
      @synced_model =
        id: 'some_other_id'
        isSynced: -> true
      @collection.models = [@fresh_model, @synced_model]

    it 'collects id, JSON and version of all models that were never synced', ->
      entry =
        id: 'some_id'
        attributes:
          attribute: 'some_value'
        version: 'some_hash'
      expect(@collection.freshModels()).toEqual([entry])
      
    it 'marks the models as synced if the markAsSynced option is set', ->  
      expect(@fresh_model.isSynced()).toBeFalsy()
      @collection.freshModels(markAsSynced: true)
      expect(@fresh_model.isSynced()).toBeTruthy()

  describe '#changedModels', ->
    beforeEach ->
      class TestCollection extends Backbone.Collection
      @collection = new TestCollection([], modelName: 'TestModel')
      model =
        id: 'some_id'
        hasPatches: -> true
        oldVersion: -> 'some_hash'
      @collection.models = [model]

    it 'collects the ids of all models with patches', ->
      models = @collection.changedModels()
      expect(models).toEqual [{id: 'some_id', old_version: 'some_hash'}]

    it 'does not collect ids of models with no patches', ->
      model =
        id: 'some_other_id'
        hasPatches: -> false
      @collection.models = [model]
      expect(@collection.changedModels()).not.toContain "some_other_id"

  describe '#processUpdates', ->
    beforeEach ->
      @model = new Backbone.Model
      @rebaseStub = sinon.stub(@model, 'rebase', -> @)
      class TestCollection extends Backbone.Collection
      @collection = new TestCollection([], modelName: 'TestModel')
      @syncUpdatesStub = sinon.stub(@collection, 'syncUpdates')

    it 'rebases each model that is found in the collection', ->
      @getStub = sinon.stub(@collection, 'get', (id) =>
        @model if id == 'id'
      )
      @collection.processUpdates(
        id: {attribute: 'value'}
        other_id: {attribute: 'other_value'}
      )
      expect(@rebaseStub).toHaveBeenCalledWith(attribute: 'value')
      expect(@rebaseStub).not.
        toHaveBeenCalledWith(attribute: 'other_value')

    it 'publishes all successfully updated models to the server', ->
      @model = new Backbone.Model
      @rebaseStub = sinon.stub(@model, 'rebase', ->
        @out ||= [false, @]
        @out.pop()
      )
      @getStub = sinon.stub(@collection, 'get', => @model)
      @collection.processUpdates(
        id: {attribute: 'value'}
        other_id: {attribute: 'other_value'}
      )
      expect(@syncUpdatesStub).toHaveBeenCalledWith([@model])

  describe '#syncUpdates', ->
    beforeEach ->
      class TestCollection extends Backbone.Collection
      @collection = new TestCollection([], modelName: 'TestModel')
      @message = undefined
      @publishStub = sinon.stub(@collection.fayeClient, "publish", (message) =>
        @message = message
      )

    it 'publishes all updated models to the server', ->
      @collection.syncUpdates(['updated', 'models'])
      expect(@message.updates).toEqual(['updated', 'models'])











