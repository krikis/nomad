describe 'Sync', ->
  describe 'changedObjects', ->
    beforeEach ->
      class TestCollection extends Backbone.Collection
      @collection = new TestCollection([], modelName: 'TestModel')
      model =
        id: 'some_id'
        hasPatches: -> true
      model._versioning = {oldVersion: 'some_hash'}
      @collection.models = [model]

    it 'collects the ids of all models with patches', ->
      objects = @collection.changedObjects()
      expect(objects).toEqual [{id: 'some_id', old_version: 'some_hash'}]

    it 'does not collect ids of models with no patches', ->
      model =
        id: 'some_other_id'
        hasPatches: -> false
      @collection.models = [model]
      expect(@collection.changedObjects()).not.toContain "some_other_id"

  describe 'prepareSync', ->
    beforeEach ->
      @message = undefined
      @publishStub = sinon.stub(BackboneSync.FayeClient::, "publish", (message) =>
        @message = message
      )
      @changedObject = sinon.stub()
      class TestCollection extends Backbone.Collection
      @collection = new TestCollection([], modelName: 'TestModel')
      @changedObjectsStub = sinon.stub(@collection, 'changedObjects', => [@changedObject])

    afterEach ->
      @publishStub.restore()
      @changedObjectsStub.restore()

    it 'publishes the model name to the server', ->
      @collection.prepareSync()
      expect(@message.model_name).toEqual @collection.modelName

    it 'publishes Nomad.clientId to the server', ->
      @collection.prepareSync()
      expect(@message.client_id).toEqual Nomad.clientId

    it 'publishes a list of changed objects to the server', ->
      @collection.prepareSync()
      expect(@message.object_ids).toEqual [@changedObject]
      
