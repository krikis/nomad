Benches = @Benches ||= {}

Benches.setupSyncConflict = (next) ->
  # delete window.client to speed up tests
  delete window.client
  class Post extends Backbone.Model
  class TestCollection extends Backbone.Collection
    model: Post
  @collection = new TestCollection
  @createSpy  = sinon.spy(@collection.fayeClient, 'create' )
  @updateSpy  = sinon.spy(@collection.fayeClient, 'update' )
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
  @dbResetSpy       = sinon.spy(@secondCollection.fayeClient, '_dbReset')  
  # clear all data stores
  @secondCollection.fayeClient._resetDb()
  @waitsFor (->
    @dbResetSpy.callCount >= 1
  ), 'second client to be in sync', 1000, (->
    # reset all spies
    @createSpy.reset()
    @updateSpy.reset()
    @secondCreateSpy.reset()
    @secondUpdateSpy.reset()
    @dbResetSpy.reset()
    next.call(@)
  )
  return

Benches.beforeSyncConflict = (next) ->
  @model = new @Post
    title: 'some_title'
    content: 'some_content'
  @collection.create @model
  @collection.syncModels()
  @waitsFor (->
    @createSpy.callCount >= 1 and @secondCreateSpy.callCount >= 1
  ), 'create multicast', 1000, (->    
    # make sure the second client misses the first client update
    @secondCollection.fayeClient._offline()
    # update the model and sync it
    @model.save
      title: 'other_title'
    @collection.syncModels()
    @waitsFor (->
      @updateSpy.callCount >= 2 and @secondUpdateSpy.callCount >= 2
    ), 'update multicast', 1000, (->    
      @updateSpy.reset()
      @secondUpdateSpy.reset()
      # take the second client back online
      @secondCollection.fayeClient._online()
      # create a conflicting update
      _.last(@secondCollection.models).save
        content: """
                 Lorem ipsum dolor sit amet, consectetur adipiscing elit. Ut consectetur luctus libero, sed dapibus eros pellentesque sed. Pellentesque porta, enim id ornare congue, augue quam consequat neque, a tempor arcu arcu sit amet tellus. Ut at neque massa, ac placerat odio. Nullam hendrerit libero hendrerit ligula imperdiet volutpat. Suspendisse potenti. Quisque eget gravida lectus. Aliquam lorem tellus, consectetur eu tincidunt nec, vulputate ac elit.

                 Integer tristique aliquam massa id ornare. Sed fringilla semper felis dignissim eleifend. Duis porta bibendum lacus non dictum. Proin quis mauris adipiscing libero dignissim lobortis sed nec lectus. Ut nibh sapien, egestas id ullamcorper nec, aliquet ac leo. Aliquam convallis mi id mauris aliquet congue. Aenean fringilla elementum consectetur. Phasellus non dolor sit amet nulla hendrerit scelerisque quis eget nisi. Vivamus aliquet tincidunt vulputate.

                 Ut ut ipsum nec mi ornare aliquet. Donec euismod felis accumsan mi adipiscing pharetra condimentum velit tincidunt. Fusce facilisis blandit leo vel aliquet. Curabitur iaculis, dolor sit amet dapibus ultricies, tellus odio tincidunt felis, sed rutrum ipsum nisl sed diam. Aliquam lacus nisi, blandit vitae sodales ut, tempor ut enim. Integer bibendum rutrum sapien, sed dictum velit eleifend vitae. Duis convallis lectus id felis ornare eget vehicula ligula ultrices. Nullam tempus porttitor varius. Etiam porttitor commodo faucibus. Sed tempus pulvinar scelerisque. Cras sit amet leo tortor. Proin tempor, risus ac tempor venenatis, turpis nibh rhoncus magna, at scelerisque ipsum libero non elit. Sed sem metus, rutrum at consequat eget, sodales vel nibh. Fusce pellentesque turpis nec justo pretium a auctor odio porta. Proin eleifend libero vitae tellus semper pellentesque.

                 Suspendisse gravida tortor eu sem tincidunt consectetur. Etiam posuere porta ligula, non aliquam nunc feugiat at. Nunc accumsan augue non est varius euismod. Ut eu purus sem. Aliquam nec erat eget lectus porttitor pellentesque sed vel ante. In aliquet lacinia arcu, sed ultrices diam viverra nec. Donec varius commodo erat, vitae faucibus dui viverra at. Phasellus cursus, dui ut ornare tincidunt, ligula tortor vestibulum neque, sed rutrum tellus dui semper massa. Morbi tincidunt, justo in bibendum egestas, nisl urna congue nulla, vitae consequat mauris nibh non turpis. Proin volutpat euismod mauris ac lacinia. Donec sagittis interdum gravida.

                 Sed consectetur elementum leo ut tempus. Vivamus placerat elementum convallis. Maecenas hendrerit iaculis ullamcorper. Curabitur fermentum orci et lorem pulvinar sit amet interdum est scelerisque. Suspendisse viverra elit at elit porta sit amet laoreet risus vestibulum. Donec vehicula sem et odio consequat tincidunt. Nullam tortor ante, dignissim id molestie quis, feugiat a mi. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas.
                 """
      next.call(@)
    )
  )
  return

Benches.syncConflict = (next) ->  
  @secondCollection.syncModels()
  @waitsFor (->
    @updateSpy.callCount >= 1 and @secondUpdateSpy.callCount >= 2
  ), 'final update multicast', 1000, (->
    next.call(@)
  )
  return

Benches.afterSyncConflict = (next) ->
  @createSpy.reset()
  @updateSpy.reset()
  @secondCreateSpy.reset()
  @secondUpdateSpy.reset()
  next.call(@)
  return

Benches.cleanupSyncConflict = (next) ->
  @collection.leave()
  @secondCollection.leave()
  # cleanup localStorage for collections
  @collection._cleanup()
  @secondCollection._cleanup()
  next.call(@)
  return
  