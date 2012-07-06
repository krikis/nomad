Benches = @Benches ||= {}

Benches.beforeSyncCreate = ->
  # delete window.client to speed up tests
  delete window.client
  window.localStorage.clear()
  class Post extends Backbone.Model
  class TestCollection extends Backbone.Collection
    model: Post
  @collection = new TestCollection
  @resolveSpy = sinon.spy(@collection.fayeClient, 'resolve')
  @createSpy  = sinon.spy(@collection.fayeClient, 'create' )
  @Post = Post
  # create second client
  class SecondPost extends Backbone.Model
    clientId: 'second_client'
  class SecondCollection extends Backbone.Collection
    model: SecondPost
    clientId: 'second_client'
    fayeClient: 'faye_client'
    initialize: ->
      @fayeClient = new BackboneSync.FayeClient @,
        modelName: 'Post'
        client: new Faye.Client("http://nomad.dev:9292/faye")
  @secondCollection = new SecondCollection
  @secondCreateSpy  = sinon.spy(@secondCollection.fayeClient, 'create')
  @secondUpdateSpy  = sinon.spy(@secondCollection.fayeClient, 'update')
  @waitsFor (->
    @secondCollection.fayeClient.client.getState() == 'CONNECTED'
  ), 'second client to connect', 1000, (->
    @model = new @Post
      title: 'some_title'
      content: 'some_content'
    @collection.create @model
  )
  return

Benches.afterSyncCreate = ->  
  @collection.leave()
  @secondCollection.leave()
  return

Benches.syncCreate = ->
  @collection.syncModels()
  @waitsFor (->
    @createSpy.callCount >= 1 and @secondCreateSpy.callCount >= 1
  ), 'create multicast', 1000
  return