describe 'prepareSync', ->
  beforeEach ->
    @fayeClientSpy = sinon.stub(BackboneSync.FayeClient::, 'receive', (message)->
      window.receive_called = true
      console.log message
    )
    class TestCollection extends Backbone.Collection
    @collection = new TestCollection
    model =
      id: 'some_id'
      hasPatches: -> true
    @collection.models = [model]

  afterEach ->
    @fayeClientSpy.restore()

  it 'publishes the channel and a list of locks to the server', ->
    runs ->
      @collection.prepareSync()
    waitsFor (->
      window.receive_called
    ), 'receive to get called', 5000
    runs ->
      expect(@fayeClientSpy).toHaveBeenCalledWith({test: 'message'})