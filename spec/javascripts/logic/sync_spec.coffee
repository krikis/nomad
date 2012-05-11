describe 'Sync', ->
  describe 'prepareSync', ->
    beforeEach ->
      @publishStub = sinon.stub(BackboneSync.FayeSubscriber::, "publish")
      TestCollection = Backbone.Collection.extend()
      
    afterEach ->
      @publishStub.restore()
    
    it 'publishes a list of locks to the server', ->
      
  