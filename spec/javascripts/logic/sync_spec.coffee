describe 'Sync', ->
  describe 'changedObjects', ->
    beforeEach ->
      class TestCollection extends Backbone.Collection
      @collection = new TestCollection([], channel: 'testChannel')
      model =
        id: 'some_id'
        hasPatches: -> true
      @collection.models = [model]

    it 'collects the ids of all models with patches', ->
      objects = @collection.changedObjects()
      expect(objects).toEqual ["some_id"]

    it 'does not collect ids of models with no patches', ->
      model =
        id: 'some_other_id'
        hasPatches: -> false
      @collection.models = [model]
      expect(@collection.changedObjects()).not.toContain "some_other_id"

  describe 'prepareSync', ->
    beforeEach ->
      @publishStub = sinon.stub(BackboneSync.FayeClient::, "publish")
      class TestCollection extends Backbone.Collection
      @collection = new TestCollection([], channel: 'testChannel')
      model =
        id: 'some_id'
        hasPatches: -> true
      @collection.models = [model]

    afterEach ->
      @publishStub.restore()

    it 'publishes the channel and a list of changed objects to the server', ->
      @collection.prepareSync()
      expect(@publishStub).toHaveBeenCalledWith
        model: 'testChannel'
        object_ids: ['some_id']
