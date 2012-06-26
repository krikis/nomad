describe 'VersionedModel using preSync', ->

  beforeEach ->
    # delete window.client instead of waiting for unsubscribes to get acknowledged
    delete window.client
    window.localStorage.clear()
    class Post extends Backbone.Model
    class TestCollection extends Backbone.Collection
      model: Post
    @collection = new TestCollection
    @resolveSpy = sinon.spy(@collection.fayeClient, 'resolve')
    @createSpy  = sinon.spy(@collection.fayeClient, 'create' )
    @updateSpy  = sinon.spy(@collection.fayeClient, 'update' )
    @Post = Post

  afterEach ->
    @collection.leave()

  context 'when it is freshly created', ->
    beforeEach ->
      @now = '2012-06-12T14:24:46Z'
      @model = new @Post
        title: 'some_title'
        content: 'some_content'
      @forwardToSpy = sinon.spy(@model, '_forwardTo')
      @model._versioning = {}
      @model._versioning.createdAt = @now
      @model._versioning.updatedAt = @now
      @collection.create @model

    it 'is not synced', ->
      expect(@model.isSynced()).toBeFalsy()

    it 'has patches', ->
      expect(@model.hasPatches()).toBeTruthy()

    context 'and it is presynced', ->
      beforeEach ->
        runs ->
          @model._versioning.updatedAt = @now
          @collection.preSync()
        waitsFor (->
          @resolveSpy.callCount > 0
        ), 'preSync acknowledgement', 1000

      it 'receives a presync acknowledgement from the server', ->
        expect(@resolveSpy).toHaveBeenCalledWith([])

      context 'and synced', ->
        beforeEach ->
          waitsFor (->
            @createSpy.callCount > 0
          ), 'create multicast', 1000

        it 'receives a create', ->
          expect(@createSpy).toHaveBeenCalled()

        it 'is synced', ->
          expect(@model.isSynced()).toBeTruthy()

        it 'is forwarded to its last version', ->
          expect(@model.hasPatches()).toBeFalsy()

        it 'receives a sync acknowledgement', ->
          waitsFor (->
            @resolveSpy.callCount > 1
          ), 'sync acknowledgement', 1000
          runs ->
            expect(@resolveSpy).toHaveBeenCalledWith([])
            
        
  #
  # it 'updates a model on the server', ->
  #   runs ->
  #     @collection.preSync()
  #   waitsFor (->
  #     @createSpy.callCount > 0
  #   ), 'create multicast', 1000
  #   runs ->
  #     @model.save
  #       title: 'other_title'
  #       content: 'other_content'
  #     expect(@model.hasPatches()).toBeTruthy()
  #     @model._versioning.updatedAt = @now
  #     @collection.preSync()
  #   waitsFor (->
  #     @updateSpy.callCount > 3
  #   ), 'preSync acknowledgement', 1000
  #   runs ->
  #     expect(@updateSpy).toHaveBeenCalledWith({})
  #   waitsFor (->
  #     @updateSpy.callCount > 4
  #   ), 'update multicast', 1000
  #   runs ->
  #     args = {}
  #     attributes = _.clone @model.attributes
  #     delete attributes.id
  #     version = {}
  #     _.each _.properties(@model.version()), (key) =>
  #       version[key] = @model.version()[key]
  #     attributes.remote_version = version
  #     attributes.created_at = @model.createdAt()
  #     attributes.updated_at = @model.updatedAt()
  #     args[@model.id] = attributes
  #     expect(@updateSpy).toHaveBeenCalledWith(args)
  #     expect(@model.hasPatches()).toBeFalsy()
  #   waitsFor (->
  #     @updateSpy.callCount > 5
  #   ), 'sync acknowledgement', 1000
  #   runs ->
  #     expect(@updateSpy).toHaveBeenCalledWith({})
  #
  # context 'when a second client comes into play', ->
  #   beforeEach ->
  #     class SecondModel  extends Backbone.Model
  #       clientId: 'second_client'
  #
  #     class SecondClient extends Backbone.Collection
  #       model: SecondModel
  #       clientId: 'second_client'
  #       fayeClient: 'faye_client'
  #       initialize: ->
  #         @fayeClient = new BackboneSync.FayeClient @,
  #           modelName: 'Post'
  #           client: new Faye.Client("http://nomad.dev:9292/faye")
  #     @secondCollection = new SecondClient
  #     @secondUpdateSpy  = sinon.spy(@secondCollection.fayeClient, 'update')
  #
  #   afterEach ->
  #     @secondCollection.leave()
  #
  #   it 'rebases a model after a server update', ->
  #     waits(200)
  #     runs ->
  #       @collection.preSync()
  #     waits(200)
  #     runs ->
  #       @secondCollection.leave()
  #     waits(200)
  #     runs ->
  #       @model.save
  #         title: 'other_title'
  #       @collection.preSync()
  #     waits(200)
  #     runs ->
  #       @secondCollection.fayeClient.subscribe()
  #     waits(200)
  #     runs ->
  #       _.first(@secondCollection.models).save
  #         content: 'other_content'
  #       @secondCollection.preSync()
  #     waitsFor (->
  #       @secondUpdateSpy.callCount > 2
  #     ), 'preSync acknowledgement', 1000
  #     runs ->
  #       expect(@secondUpdateSpy).toHaveBeenCalledWith({})
  #       expect(@model.get('title')).toEqual('other_title')
  #       expect(@model.get('content')).toEqual('other_content')
  #
  #
  #
  #
