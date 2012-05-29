describe 'Sync', ->
  
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
      objects = @collection.changedModels()
      expect(objects).toEqual [{id: 'some_id', old_version: 'some_hash'}]

    it 'does not collect ids of models with no patches', ->
      model =
        id: 'some_other_id'
        hasPatches: -> false
      @collection.models = [model]
      expect(@collection.changedModels()).not.toContain "some_other_id"

  describe '#prepareSync', ->
    beforeEach ->
      @message = undefined
      class TestCollection extends Backbone.Collection
      @collection = new TestCollection([], modelName: 'TestModel')
      @publishStub = sinon.stub(@collection.fayeClient, "publish", (message) =>
        @message = message
      )

    afterEach ->
      @publishStub.restore()
      @changedModelsStub.restore()   
      
    context 'when there are changed models', ->
      beforeEach ->
        @changedModel = sinon.stub()
        @changedModelsStub = sinon.stub(@collection, 'changedModels', => [@changedModel])

      it 'publishes the model name to the server', ->
        @collection.prepareSync()
        expect(@message.model_name).toEqual @collection.modelName

      it 'publishes Nomad.clientId to the server', ->
        @collection.prepareSync()
        expect(@message.client_id).toEqual Nomad.clientId

      it 'publishes a list of changed models to the server', ->
        @collection.prepareSync()
        expect(@message.objects).toEqual [@changedModel]
      
    context 'when there are no changed models', ->
      beforeEach ->
        @changedModelsStub = sinon.stub(@collection, 'changedModels', => [])
        
      it 'does not publish to the server', ->
        @collection.prepareSync()
        expect(@publishStub).not.toHaveBeenCalled()
        
      it 'sends all fresh models to the server'

  describe '#processUpdates', ->
    beforeEach ->
      @model = new Backbone.Model
      @rebaseStub = sinon.stub(@model, 'rebase', -> @)
      class TestCollection extends Backbone.Collection
      @collection = new TestCollection([], modelName: 'TestModel')
      @syncModelsStub = sinon.stub(@collection, 'syncModels')

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
      expect(@syncModelsStub).toHaveBeenCalledWith([@model])
      
  describe '#syncModels', ->
    beforeEach ->
      class TestCollection extends Backbone.Collection
      @collection = new TestCollection([], modelName: 'TestModel')
      @freshModelsStub = sinon.stub(@collection, 'freshModels')    
    
    it 'collects all models that were never synced', ->
      @collection.syncModels()
    
    
    it 'publishes all updated and fresh models to the server'
    
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
    
      
       
       
       
       
       
       
       
       
       
       
