describe 'sync', ->

  beforeEach ->
    # delete faye client created during isolated tests
    unless window.acceptance_client?
      delete window.client
      window.acceptance_client = true
    # create a wrapper around the receive method so that it sets window.receive_called
    @receiveSpy = sinon.spy(BackboneSync.FayeClient::, 'receive')
    @resolveSpy = sinon.spy(BackboneSync.FayeClient::, 'resolve')
    @createSpy  = sinon.spy(BackboneSync.FayeClient::, 'create' )
    @updateSpy  = sinon.spy(BackboneSync.FayeClient::, 'update' )
    @destroySpy = sinon.spy(BackboneSync.FayeClient::, 'destroy')
    class Post           extends Backbone.Model
    class TestCollection extends Backbone.Collection
      model: Post
    @collection = new TestCollection
    now = '2012-06-12T14:24:46Z'
    @model = new Post
      title: 'some_title'
      content: 'some_content'
      created_at: now
      updated_at: now
      # TODO strip miliseconds from date string representation
      # created_at: JSON.stringify(new Date())
      # updated_at: JSON.stringify(new Date())
    @collection.create @model

  afterEach ->
    window.client.unsubscribe('/sync/Post')
    window.client.unsubscribe('/sync/Post/some_unique_id')
    @receiveSpy.restore()
    @resolveSpy.restore()
    @createSpy .restore()
    @updateSpy .restore()
    @destroySpy.restore()

  it 'syncs a newly created model to the server', ->
    runs ->
      @collection.preSync()
    waitsFor (->
      @resolveSpy.callCount > 0
    ), 'preSync acknowledgement', 1000
    runs ->
      expect(@resolveSpy).toHaveBeenCalledWith([])
    waitsFor (->
      @createSpy.callCount > 0
    ), 'create ackowledgement', 5000
    runs ->
      args = {}
      attributes = @model.attributes
      delete attributes.id
      version = {}
      _.each _.keys(@model.version()), (key) =>
        version[key] = @model.version()[key]
      attributes.remote_version = version
      args[@model.id] = attributes
      expect(@createSpy).toHaveBeenCalledWith(args)
    waitsFor (->
      @resolveSpy.callCount > 1
    ), 'sync acknowledgement', 1000
    runs ->
      expect(@resolveSpy).toHaveBeenCalledWith([])

  it 'syncs an updated model to the server', ->
    runs ->
      @collection.preSync()
    waits(50)
    runs ->
      @model.save
        title: 'other_title'
        content: 'other_content'
      @collection.preSync()
    waitsFor (->
      @updateSpy.callCount > 2
    ), 'update to get called', 5000
    runs ->
      expect(@updateSpy).toHaveBeenCalledWith({})








