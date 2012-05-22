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
      @message = undefined
      @publishStub = sinon.stub(BackboneSync.FayeClient::, "publish", (message) =>
        @message = message
      )
      class TestCollection extends Backbone.Collection
      @collection = new TestCollection([], channel: 'testChannel')
      model =
        id: 'some_id'
        hasPatches: -> true
      @collection.models = [model]

    afterEach ->
      @publishStub.restore()

    it 'publishes the channel to the server', ->
      @collection.prepareSync()
      expect(@message.model).toEqual @collection.channel

    it 'publishes Nomad.clientId to the server', ->
      @collection.prepareSync()
      expect(@message.client_id).toEqual Nomad.clientId

    it 'publishes a list of changed objects to the server', ->
      @collection.prepareSync()
      expect(@message.object_ids).toEqual ['some_id']
      
