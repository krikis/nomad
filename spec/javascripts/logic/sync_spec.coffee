describe 'Sync', ->
  describe 'prepareSync', ->
    beforeEach ->
      @publishStub = sinon.stub(BackboneSync.FayeClient::, "publish")
      TestCollection = Backbone.Collection.extend(
        initialize: ->
          @fayeClient = new BackboneSync.FayeClient(@,
            channel: @constructor.name.toLowerCase()
          )
      )
      @collection = new TestCollection
      
    afterEach ->
      @publishStub.restore()
    
    it 'publishes a list of locks to the server', ->
      @collection.prepareSync()
      expect(@publishStub).toHaveBeenCalled()
  