describe "FayeClient", ->
  beforeEach ->
    @fayeClientStub = {}
    @fayeClientStub.subscribe = sinon.stub()
    @fayeClientStub.publish = sinon.stub()
    @clientConstructorStub = sinon.stub(Faye, "Client")
    @clientConstructorStub.returns @fayeClientStub
    @collection = new Backbone.Collection([], modelName: 'TestModel')
    @modelName = 'TestModel'

  afterEach ->
    @clientConstructorStub.restore()
    # remove stub from window.client
    delete window.client

  it "exists", ->
    expect(BackboneSync).toBeDefined()

  describe "new", ->
    beforeEach ->
      # stub before creation because of callback binding
      @subscribeStub = sinon.stub(BackboneSync.FayeClient::, "subscribe")
      @subscriber = new BackboneSync.FayeClient @collection,
                                                channel: @modelName

    afterEach ->
      @subscribeStub.restore()

    it "fires up the Faye client", ->
      expect(@clientConstructorStub).toHaveBeenCalled()

    it "sets the collection and channel property", ->
      expect(@subscriber.collection).toEqual @collection
      expect(@subscriber.channel).toEqual @modelName

    it "calls the subscribe method", ->
      expect(@subscribeStub).toHaveBeenCalled()

    it "does not fire up a new Faye client if one is already running", ->
      @otherSubscriber = new BackboneSync.FayeClient @collection,
                                                     channel: @modelName
      expect(@clientConstructorStub).toHaveBeenCalledOnce()

  describe "#publish", ->
    beforeEach ->
      @subscriber = new BackboneSync.FayeClient @collection,
                                                channel: @modelName

    it "calls the publish method on the faye client object", ->
      data = sinon.stub()
      @subscriber.publish data
      expect(@fayeClientStub.publish).
        toHaveBeenCalledWith("/server/" + @modelName, data)

  describe "#subscribe", ->
    beforeEach ->
      @subscriber = new BackboneSync.FayeClient @collection,
                                                channel: @modelName

    it "subscribes the wrapped client to the channel", ->
      expect(@fayeClientStub.subscribe).
        toHaveBeenCalledWith("/sync/" + @modelName,
                             @subscriber.receive,
                             @subscriber)

    it 'subscribes the wrapped client to a personal channel', ->
      expect(@fayeClientStub.subscribe).
          toHaveBeenCalledWith("/sync/#{@modelName}/#{Nomad.clientId}",
                               @subscriber.receive,
                               @subscriber)

  describe "#receive", ->
    beforeEach ->
      @subscriber = new BackboneSync.FayeClient @collection,
                                                channel: @modelName
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





