describe 'sync', ->

  beforeEach ->
    # delete faye client created during isolated tests
    unless window.acceptance_client?
      delete window.client
      window.acceptance_client = true
    # create a wrapper around the receive method so that it sets window.receive_called
    @fayeReceiveSpy = sinon.spy(BackboneSync.FayeClient::, 'receive')
    @fayeUpdateSpy  = sinon.spy(BackboneSync.FayeClient::, 'update')
    class Post           extends Backbone.Model
    class TestCollection extends Backbone.Collection
      model: Post
    @collection = new TestCollection
    @model = new Post
      title: 'some_title'
      content: 'some_content'
    @collection.create @model

  afterEach ->
    window.client.unsubscribe('/sync/Post')
    window.client.unsubscribe('/sync/Post/some_unique_id')
    @fayeReceiveSpy.restore()
    @fayeUpdateSpy.restore()

  context 'when syncing a newly created object to the server', ->
    it 'receives an acknowledgement', ->
      runs ->
        @collection.preSync()
      waitsFor (->
        @fayeReceiveSpy.callCount > 0
      ), 'receive to get called', 5000
      runs ->
        expect(@fayeReceiveSpy).toHaveBeenCalledWith(update: {}, resolve: [])

  context 'when syncing a changed object to the server', ->
    it 'publishes a list of changed objects to the server
        and receives a list of concurrently changed objects back', ->
      runs ->
        @collection.preSync()
      waits(10)
      runs ->
        @model.save
          title: 'other_title'
          content: 'other_content'
        @collection.preSync()
      waitsFor (->
        @fayeUpdateSpy.callCount > 1
      ), 'update to get called', 5000
      runs ->
        expect(@fayeUpdateSpy).toHaveBeenCalledWith({})