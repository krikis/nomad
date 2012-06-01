describe 'sync', ->

  beforeEach ->
    # delete faye client created during isolated tests
    unless window.acceptance_client?
      delete window.client
      window.acceptance_client = true

  describe 'sync a newly created object to the server', ->
    beforeEach ->
      # create a wrapper around the receive method so that it sets window.receive_called
      window.receive_called = false
      originalReceive = BackboneSync.FayeClient::receive
      @fayeReceiveStub = sinon.stub(BackboneSync.FayeClient::, 'receive', (message) ->
        originalReceive.apply(@, arguments)
        window.receive_called = true
      )
      class Post extends Backbone.Model
      class TestCollection extends Backbone.Collection
        model: Post
      @collection = new TestCollection
      @model = new Post
        title: 'some_title'
        content: 'some_content'
      @collection.create @model

    afterEach ->
      @fayeReceiveStub.restore()

    it 'marks a model as synced and receives an acknowledgement', ->
      runs ->
        expect(@model.isSynced()).toBeFalsy()
        @collection.preSync()
        expect(@model.isSynced()).toBeTruthy()
      waitsFor (->
        window.receive_called
      ), 'receive to get called', 5000
      runs ->
        expect(@fayeReceiveStub).toHaveBeenCalledWith({ conflict: [], ack: [@model.id] })



  # describe 'sync a changed object to the server', ->
  #   beforeEach ->
  #     class Post extends Backbone.Model
  #     class TestCollection extends Backbone.Collection
  #       model: Post
  #     @collection = new TestCollection
  #     @model = new Post
  #       title: 'some_title'
  #       content: 'some_content'
  #     @collection.create @fresh_model
  #
  #   afterEach ->
  #     @fayePublishSpy.restore()
  #     @fayeReceiveStub.restore()
  #
  #   it 'publishes a list of changed objects to the server
  #       and receives a list of concurrently changed objects back', ->
  #     runs ->
  #       @collection.preSync()
  #     waitsFor (->
  #       window.receive_called
  #     ), 'receive to get called', 5000
  #     runs ->
  #       expect(@fayeReceiveStub).toHaveBeenCalledWith({ conflict: [], ack: [@fresh_model.id] })