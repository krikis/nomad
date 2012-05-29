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

      it 'publishes all fresh models to the server', ->
        @collection.preSync()
        expect(@message.creates).toEqual(['new', 'models'])
      
    context 'when there are changed models', ->
      beforeEach ->
        @changedModelsStub = sinon.
          stub(@collection, 'changedModels', => ['changed', 'models'])

      it 'publishes the model name to the server', ->
        @collection.preSync()
        expect(@message.model_name).toEqual @collection.modelName

      it 'collects all changed models', ->
        @collection.preSync()
        expect(@changedModelsStub).toHaveBeenCalled()

      it 'publishes a list of changed models to the server', ->
        @collection.preSync()
        expect(@message.changed).toEqual(['changed', 'models'])
      
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
      @fresh_model = 
        id: 'some_id' 
        isFresh: -> true
        version: -> 'some_hash'
      @synced_model = 
        id: 'some_other_id'
        isFresh: -> false
      @collection.models = [@fresh_model, @synced_model]       

    it 'collects JSON and version of all models that were never synced', ->
      entry = 
        model: '{"id":"some_id"}'
        version: 'some_hash'
      expect(@collection.freshModels()).toEqual([entry])
  
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
      
       
       
       
       
       
       
       
       
       
       
