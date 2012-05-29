describe 'Sync', ->
  describe '#changedModels', ->
    beforeEach ->
      class TestCollection extends Backbone.Collection
      @collection = new TestCollection([], modelName: 'TestModel')
      model =
        id: 'some_id'
        hasPatches: -> true
      model._versioning = {oldVersion: 'some_hash'}
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
      @changedObject = sinon.stub()
      class TestCollection extends Backbone.Collection
      @collection = new TestCollection([], modelName: 'TestModel')
      @publishStub = sinon.stub(@collection.fayeClient, "publish", (message) =>
        @message = message
      )
      @changedModelsStub = sinon.stub(@collection, 'changedModels', => [@changedObject])

    afterEach ->
      @publishStub.restore()
      @changedModelsStub.restore()      

    it 'publishes the model name to the server', ->
      @collection.prepareSync()
      expect(@message.model_name).toEqual @collection.modelName

    it 'publishes Nomad.clientId to the server', ->
      @collection.prepareSync()
      expect(@message.client_id).toEqual Nomad.clientId

    it 'publishes a list of changed objects to the server', ->
      @collection.prepareSync()
      expect(@message.objects).toEqual [@changedObject]

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
              
    it 'publishes each successfully updated model to the server', ->
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
      
       
       
       
       
       
       
       
       
       
       
