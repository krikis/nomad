describe 'prepareSync', ->
  beforeEach ->
    window.receive_called = false
    @fayeClientStub = sinon.stub(BackboneSync.FayeClient::, 'receive', (message)->
      window.receive_called = true
    )
    class TestCollection extends Backbone.Collection
    @collection = new TestCollection([], channel: 'Post')
    model =
      id: 'some_id'
      hasPatches: -> true
    @collection.models = [model]

  afterEach ->
    @fayeClientStub.restore()

  it 'publishes the channel and a list of changed objects to the server', ->
    runs ->
      @collection.prepareSync()
    waitsFor (->
      window.receive_called
    ), 'receive to get called', 5000
    runs ->
      expect(@fayeClientStub).toHaveBeenCalledWith({objects: []})