describe 'syncmodels', ->

  beforeEach ->
    # delete faye client created during isolated tests
    unless window.acceptance_client?
      delete window.client
      window.acceptance_client = true
    @receiveSpy = sinon.spy(BackboneSync.FayeClient::, 'receive')
    @resolveSpy = sinon.spy(BackboneSync.FayeClient::, 'resolve')
    @createSpy  = sinon.spy(BackboneSync.FayeClient::, 'create' )
    @updateSpy  = sinon.spy(BackboneSync.FayeClient::, 'update' )
    @destroySpy = sinon.spy(BackboneSync.FayeClient::, 'destroy')
    class Post           extends Backbone.Model
    class TestCollection extends Backbone.Collection
      model: Post
    @collection = new TestCollection
    @now = '2012-06-12T14:24:46Z'
    @model = new Post
      title: 'some_title'
      content: 'some_content'
    @model._versioning = {}
    @model._versioning.createdAt = @now
    @model._versioning.updatedAt = @now
    @collection.create @model

  afterEach ->
    window.client.unsubscribe('/sync/Post')
    window.client.unsubscribe('/sync/Post/some_unique_id')
    window.client.unsubscribe('/sync/Post/some_other_id')
    @receiveSpy.restore()
    @resolveSpy.restore()
    @createSpy .restore()
    @updateSpy .restore()
    @destroySpy.restore()

  it 'creates a model on the server', ->
    runs ->
      expect(@model.isSynced()).toBeFalsy()
      expect(@model.hasPatches()).toBeTruthy()
      @model._versioning.updatedAt = @now
      @collection.syncModels()
    waitsFor (->
      @createSpy.callCount > 0
    ), 'create multicast', 1000
    runs ->
      args = {}
      attributes = @model.attributes
      delete attributes.id
      version = {}
      _.each _.properties(@model.version()), (key) =>
        version[key] = @model.version()[key]
      attributes.remote_version = version
      attributes.created_at = @model.createdAt()
      attributes.updated_at = @model.updatedAt()
      args[@model.id] = attributes
      expect(@createSpy).toHaveBeenCalledWith(args)
      expect(@model.isSynced()).toBeTruthy()
      expect(@model.hasPatches()).toBeFalsy()
    waitsFor (->
      @resolveSpy.callCount > 0
    ), 'sync acknowledgement', 1000
    runs ->
      expect(@resolveSpy).toHaveBeenCalledWith([])
  
  it 'updates a model on the server', ->
    runs ->
      @collection.syncModels()
    waits(50)
    runs ->
      @model.save
        title: 'other_title'
        content: 'other_content'
      expect(@model.hasPatches()).toBeTruthy()
      @model._versioning.updatedAt = @now
      @collection.syncModels()
    waitsFor (->
      @updateSpy.callCount > 0
    ), 'update multicast', 1000
    runs ->
      args = {}
      attributes = @model.attributes
      delete attributes.id
      version = {}
      _.each _.properties(@model.version()), (key) =>
        version[key] = @model.version()[key]
      attributes.remote_version = version
      attributes.created_at = @model.createdAt()
      attributes.updated_at = @model.updatedAt()
      args[@model.id] = attributes
      expect(@updateSpy).toHaveBeenCalledWith(args)
      expect(@model.hasPatches()).toBeFalsy()
    waitsFor (->
      @updateSpy.callCount > 1
    ), 'sync acknowledgement', 1000
    runs ->
      expect(@updateSpy).toHaveBeenCalledWith({})
  
  it 'rebases a model after a server update', ->
    runs ->
      @collection.syncModels()
    waits(50)
    runs ->
      @model.save
        title: 'other_title'
      @collection.syncModels()
    waits(500)
    runs ->
      @model.save
        title: 'some_title'
      @model._forwardTo(remote_version: @model.version())
      @model.save
        content: 'other_content'
      version = new VectorClock
        some_unique_id: 1
        some_other_id: 1
      @model.setVersion(version)
      @previousId = Nomad.clientId
      Nomad.clientId = 'some_other_id'
      window.client.unsubscribe('/sync/Post')
      @collection.fayeClient.subscribe()
      @collection.syncModels()
    waitsFor (->
      @updateSpy.callCount > 3
    ), 'sync acknowledgement', 1000
    runs ->
      expect(@updateSpy).toHaveBeenCalledWith({})
      expect(@model.get('title')).toEqual('other_title')
      expect(@model.get('content')).toEqual('other_content')
      Nomad.clientId = @previousId
  
  
  
  
