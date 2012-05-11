describe 'Sync', ->
  describe 'prepareSync', ->
    beforeEach ->
      @publishStub = sinon.stub(BackboneSync.FayeSubscriber::, "publish")
      TestCollection = Backbone.Collection.extend(
        initialize: ->
          new BackboneSync.FayeSubscriber(@,
            channel: @constructor.name.toLowerCase()
          )
      )
      
    afterEach ->
      @publishStub.restore()
    
    it 'publishes a list of locks to the server', ->
      
  