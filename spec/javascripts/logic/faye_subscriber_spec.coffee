describe "FayeSubscriber", ->
  beforeEach ->
    @fayeClientStub = {}
    @fayeClientStub.subscribe = sinon.stub()
    @clientConstructorStub = sinon.stub(Faye, "Client")
    @clientConstructorStub.returns @fayeClientStub
    @collection = new Backbone.Collection
    @channel = "test_channel"
  afterEach ->
    @clientConstructorStub.restore()

  it "exists", ->
    expect(BackboneSync).toBeDefined()

  describe "new", ->
    beforeEach ->
      @subscribeStub = sinon.stub(BackboneSync.FayeSubscriber::, "subscribe")
      @subscriber = new BackboneSync.FayeSubscriber @collection,
                                                    channel: @channel
                                  
    afterEach ->
      @subscribeStub.restore()
        
    it "fires up the Faye client", ->
      expect(@clientConstructorStub).toHaveBeenCalled
      
    it "sets the collection and channel property", ->
      expect(@subscriber.collection).toEqual @collection
      expect(@subscriber.channel).toEqual @channel
      
    it "calls the subscribe method", ->
      expect(@subscribeStub).toHaveBeenCalled()
      
  describe "#subscribe", ->
    beforeEach ->
      @subscriber = new BackboneSync.FayeSubscriber @collection,
                                                    channel: @channel
                                                    
    it "calls the subscribe method on the faye client object", ->
      expect(@fayeClientStub.subscribe).
        toHaveBeenCalledWith("/sync/" + @channel, 
                             @subscriber.receive, 
                             @subscriber)
  


