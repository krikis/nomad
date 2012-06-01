describe 'sync', ->

  beforeEach ->
    # delete faye client created during isolated tests
    unless window.acceptance_client?
      delete window.client
      window.acceptance_client = true

  describe 'preSync', ->
    beforeEach ->
      window.receive_called = false
      @fayeReceiveStub = sinon.stub(BackboneSync.FayeClient::, 'receive', (message) ->
        console.log message
        window.receive_called = true
      )
      class Post extends Backbone.Model
      class TestCollection extends Backbone.Collection
        model: Post
      @collection = new TestCollection
      @fayePublishSpy = sinon.spy(@collection.fayeClient, 'publish')
      fresh_model = new Post
        id: 'some_id'
        title: 'some_title'
        content: 'some_content'
      fresh_model.isFresh = -> true
      fresh_model.hasPatches = -> false
      fresh_model.version = -> 'some_hash'
      synced_model = new Post
        id: 'some_id'
      synced_model.isFresh = -> false
      synced_model.hasPatches = -> true
      synced_model.version = -> 'some_hash'
      @collection.models = [fresh_model, synced_model]

    afterEach ->
      @fayePublishSpy.restore()
      @fayeReceiveStub.restore()

    it 'publishes a list of changed objects to the server
        and receives a list of concurrently changed objects back', ->
      runs ->
        @collection.preSync()
      waitsFor (->
        window.receive_called
      ), 'receive to get called', 5000
      runs ->
        expect(@fayeReceiveStub).toHaveBeenCalledWith({update: {}})