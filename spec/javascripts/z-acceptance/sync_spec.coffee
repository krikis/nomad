describe 'sync', ->

  beforeEach ->
    # delete faye client created during isolated tests
    unless window.acceptance_client?
      delete window.client
      window.acceptance_client = true

  describe 'preSync', ->  
    beforeEach ->
      window.receive_called = false
      @fayeClientStub = sinon.stub(BackboneSync.FayeClient::, 'receive', (message) ->
        window.receive_called = true
      )
      class TestCollection extends Backbone.Collection
      @collection = new TestCollection([], modelName: 'Post')
      fresh_model =
        id: 'some_id'
        isFresh: -> true
        hasPatches: -> false
        version: -> 'some_hash'
      synced_model =
        id: 'some_id'
        isFresh: -> false
        hasPatches: -> true
        oldVersion: -> 'some_hash'
      @collection.models = [fresh_model, synced_model]

    afterEach ->
      @fayeClientStub.restore()

    it 'publishes a list of changed objects to the server
        and receives a list of concurrently changed objects back', ->
      runs ->
        @collection.preSync()
      waitsFor (->
        window.receive_called
      ), 'receive to get called', 5000
      runs ->
        expect(@fayeClientStub).toHaveBeenCalledWith({update: {}})