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
      model =
        id: 'some_id'
        version: -> 'vector_clock'
      @collection.models = [model]

    it 'collects the ids and versions of all models', ->
      models = @collection.versionDetails()
      expect(models).toEqual [{id: 'some_id', version: 'vector_clock'}]


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











