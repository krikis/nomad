describe 'presync', ->

  beforeEach ->
    # delete faye client created during isolated tests
    # unless window.acceptance_client?
    #   delete window.client
    #   window.acceptance_client = true
    window.localStorage.clear()
    class Post extends Backbone.Model
    class TestCollection extends Backbone.Collection
      model: Post
    @collection = new TestCollection
    @resolveSpy = sinon.spy(@collection.fayeClient, 'resolve')
    @createSpy  = sinon.spy(@collection.fayeClient, 'create' )
    @updateSpy  = sinon.spy(@collection.fayeClient, 'update' )
    @destroySpy = sinon.spy(@collection.fayeClient, 'destroy')
    @now = '2012-06-12T14:24:46Z'
    @model = new Post
      title: 'some_title'
      content: 'some_content'
    @model._versioning = {}
    @model._versioning.createdAt = @now
    @model._versioning.updatedAt = @now
    @collection.create @model

  afterEach ->
    @collection.leave()

  it 'creates a model on the server', ->
    runs ->
      expect(@model.isSynced()).toBeFalsy()
      expect(@model.hasPatches()).toBeTruthy()
      @model._versioning.updatedAt = @now
      @collection.preSync()
    waitsFor (->
      @resolveSpy.callCount > 0
    ), 'preSync acknowledgement', 1000
    runs ->
      expect(@resolveSpy).toHaveBeenCalledWith([])
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
      @resolveSpy.callCount > 1
    ), 'sync acknowledgement', 1000
    runs ->
      expect(@resolveSpy).toHaveBeenCalledWith([])

  it 'updates a model on the server', ->
    runs ->
      @collection.preSync()
    waits(50)
    runs ->
      @model.save
        title: 'other_title'
        content: 'other_content'
      expect(@model.hasPatches()).toBeTruthy()
      @model._versioning.updatedAt = @now
      @collection.preSync()
    waitsFor (->
      @updateSpy.callCount > 0
    ), 'preSync acknowledgement', 1000
    runs ->
      expect(@updateSpy).toHaveBeenCalledWith({})
    waitsFor (->
      @updateSpy.callCount > 1
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
      @updateSpy.callCount > 2
    ), 'sync acknowledgement', 1000
    runs ->
      expect(@updateSpy).toHaveBeenCalledWith({})

  context 'when a second client comes into play', ->
    beforeEach ->
      class SecondModel  extends Backbone.Model
        clientId: 'second_client'

      class SecondClient extends Backbone.Collection
        model: SecondModel
        clientId: 'second_client'
        fayeClient: 'faye_client'
        initialize: ->
          @fayeClient = new BackboneSync.FayeClient @,
            modelName: 'Post'
            client: new Faye.Client("http://nomad.dev:9292/faye")
      @secondCollection = new SecondClient
      @secondUpdateSpy  = sinon.spy(@secondCollection.fayeClient, 'update')

    afterEach ->
      @secondCollection.leave()

    it 'rebases a model after a server update', ->
      waits(200)
      runs ->
        @collection.preSync()
      waits(500)
      runs ->
        @secondCollection.leave()
      waits(200)
      runs ->
        @model.save
          title: 'other_title'
        @collection.preSync()
      waits(500)
      runs ->
        @secondCollection.fayeClient.subscribe()
      waits(200)
      runs ->
        _.first(@secondCollection.models).save
          content: 'other_content'
        @secondCollection.preSync()
      waitsFor (->
        @secondUpdateSpy.callCount > 2
      ), 'preSync acknowledgement', 1000
      runs ->
        expect(@secondUpdateSpy).toHaveBeenCalledWith({})
        expect(@model.get('title')).toEqual('other_title')
        expect(@model.get('content')).toEqual('other_content')




