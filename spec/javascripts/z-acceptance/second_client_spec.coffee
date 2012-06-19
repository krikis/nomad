describe 'second_client', ->
  beforeEach ->
    window.localStorage.clear()
    class FirstModel  extends Backbone.Model
      clientId: 'first_client'

    class FirstClient extends Backbone.Collection
      model: FirstModel
      clientId: 'first_client'
      fayeClient: 'faye_client'
      initialize: ->
        @fayeClient = new BackboneSync.FayeClient @,
          modelName: 'Post'
          client: new Faye.Client("http://nomad.dev:9292/faye")

    class SecondModel  extends Backbone.Model
      clientId: 'second_client'

    class SecondClient extends Backbone.Collection
      model: FirstModel
      clientId: 'second_client'
      fayeClient: 'faye_client'
      initialize: ->
        @fayeClient = new BackboneSync.FayeClient @,
          modelName: 'Post'
          client: new Faye.Client("http://nomad.dev:9292/faye")

    @firstCollection  = new FirstClient
    @secondCollection = new SecondClient
    @resolveSpy = sinon.spy(@secondCollection.fayeClient, 'resolve')
    @createSpy  = sinon.spy(@secondCollection.fayeClient, 'create' )
    @updateSpy  = sinon.spy(@secondCollection.fayeClient, 'update' )
    @destroySpy = sinon.spy(@secondCollection.fayeClient, 'destroy')

  afterEach ->
    @firstCollection .leave()
    @secondCollection.leave()

  context 'when the first client syncs a new model', ->
    beforeEach ->
      waits(200)
      runs ->
        @firstCollection.create
          title: 'some_title'
        @firstCollection.syncModels()

    it 'creates the models created by the first client', ->
      waitsFor (->
        @createSpy.callCount > 0
      ), 'creates', 1000
      runs ->
        expect(@secondCollection.models).toBeDefined()