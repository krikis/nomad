describe "FayeClient", ->
  beforeEach ->
    delete window.client
    @fayeClientStub = {}
    @fayeClientStub.subscribe = sinon.stub()
    @fayeClientStub.publish = sinon.stub()
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
      # stub before creation because of callback binding
      @subscribeStub = sinon.stub(BackboneSync.FayeClient::, "subscribe")
      @subscriber = new BackboneSync.FayeClient @collection,
                                                    channel: @channel

    afterEach ->
      @subscribeStub.restore()

    it "fires up the Faye client", ->
      expect(@clientConstructorStub).toHaveBeenCalled()

    it "sets the collection and channel property", ->
      expect(@subscriber.collection).toEqual @collection
      expect(@subscriber.channel).toEqual @channel

    it "calls the subscribe method", ->
      expect(@subscribeStub).toHaveBeenCalled()

    it "does not fire up a new Faye client if one is already running", ->
      @otherSubscriber = new BackboneSync.FayeClient @collection,
                                                    channel: @channel
      expect(@clientConstructorStub).toHaveBeenCalledOnce()
      
  describe "#publish", ->
    beforeEach ->
      @subscriber = new BackboneSync.FayeClient @collection,
                                                    channel: @channel
                                                    
    it "calls the publish method on the faye client object", ->
      data = sinon.stub()
      @subscriber.publish data
      expect(@fayeClientStub.publish).
        toHaveBeenCalledWith("/server/" + @channel, data)

  describe "#subscribe", ->
    beforeEach ->
      @subscriber = new BackboneSync.FayeClient @collection,
                                                    channel: @channel

    it "calls the subscribe method on the faye client object", ->
      expect(@fayeClientStub.subscribe).
        toHaveBeenCalledWith("/sync/" + @channel,
                             @subscriber.receive,
                             @subscriber)

  describe "#receive", ->
    beforeEach ->
      @subscriber = new BackboneSync.FayeClient @collection,
                                                    channel: @channel
      @subscriber.method_1 = sinon.stub()
      @subscriber.method_2 = sinon.stub()

    it "calls a method for each entry in the message", ->
      @subscriber.receive
        method_1:
          id: {attribute_1: "test"}
        method_2:
          id: {attribute_2: "receive"}
      expect(@subscriber.method_1).toHaveBeenCalledWith(id: {attribute_1: "test"})
      expect(@subscriber.method_2).toHaveBeenCalledWith(id: {attribute_2: "receive"})




