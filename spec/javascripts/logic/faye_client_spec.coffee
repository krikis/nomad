describe 'FayeClient', ->
  beforeEach ->
    @fayeClientStub = {}
    @fayeClientStub.subscribe = sinon.stub()
    @fayeClientStub.publish = sinon.stub()
    @clientConstructorStub = sinon.stub(Faye, 'Client')
    @clientConstructorStub.returns @fayeClientStub
    @collection = new Backbone.Collection([], modelName: 'TestModel')
    @modelName = 'TestModel'

  afterEach ->
    @clientConstructorStub.restore()
    # remove stub from window.client
    delete window.client

  it 'exists', ->
    expect(BackboneSync).toBeDefined()

  describe 'new', ->
    beforeEach ->
      # stub before creation because of callback binding
      @backboneClientStub = sinon.stub(BackboneSync.FayeClient::, 'subscribe')
      @backboneClient = new BackboneSync.FayeClient @collection,
                                                    channel: @modelName

    afterEach ->
      @backboneClientStub.restore()

    it 'fires up the Faye client', ->
      expect(@clientConstructorStub).toHaveBeenCalled()

    it 'sets the collection and channel property', ->
      expect(@backboneClient.collection).toEqual @collection
      expect(@backboneClient.channel).toEqual @modelName

    it 'calls the subscribe method', ->
      expect(@backboneClientStub).toHaveBeenCalled()

    it 'does not fire up a new Faye client if one is already running', ->
      @otherClient = new BackboneSync.FayeClient @collection,
                                                 channel: @modelName
      expect(@clientConstructorStub).toHaveBeenCalledOnce()

  describe '#publish', ->
    beforeEach ->
      @backboneClient = new BackboneSync.FayeClient @collection,
                                                    channel: @modelName
                                                
    it 'adds the Nomad client id to the message', ->                                                
      message = {}       
      @backboneClient.publish(message)
      expect(message.client_id).toEqual(Nomad.clientId)
      
    it 'preserves client_id if it is already set', ->
      message = {client_id: 'preset_id'}       
      @backboneClient.publish(message)
      expect(message.client_id).toEqual('preset_id')

    it 'calls the publish method on the faye client object', ->
      message = sinon.stub()
      @backboneClient.publish message
      expect(@fayeClientStub.publish).
        toHaveBeenCalledWith('/server/' + @modelName, message)

  describe '#subscribe', ->
    beforeEach ->
      @backboneClient = new BackboneSync.FayeClient @collection,
                                                    channel: @modelName

    it 'subscribes the wrapped client to the channel', ->
      expect(@fayeClientStub.subscribe).
        toHaveBeenCalledWith('/sync/' + @modelName,
                             @backboneClient.receive,
                             @backboneClient)

    it 'subscribes the wrapped client to a personal channel', ->
      expect(@fayeClientStub.subscribe).
          toHaveBeenCalledWith("/sync/#{@modelName}/#{Nomad.clientId}",
                               @backboneClient.receive,
                               @backboneClient)

  describe '#receive', ->
    beforeEach ->
      @backboneClient = new BackboneSync.FayeClient @collection,
                                                channel: @modelName
      @backboneClient.method_1 = sinon.stub()
      @backboneClient.method_2 = sinon.stub()

    it 'calls a method for each entry in the message', ->
      @backboneClient.receive
        method_1:
          id: {attribute_1: 'test'}
        method_2:
          id: {attribute_2: 'receive'}
      expect(@backboneClient.method_1).
        toHaveBeenCalledWith(id: {attribute_1: 'test'})    
      expect(@backboneClient.method_2).
        toHaveBeenCalledWith(id: {attribute_2: 'receive'})
      
  describe '#update', ->
    beforeEach ->
      @processUpdatesStub = sinon.stub(@collection, 'processUpdates')
      @backboneClient = new BackboneSync.FayeClient @collection,
                                                    channel: @modelName
      
    afterEach ->
      @processUpdatesStub.restore()
      
    it 'has the collection process the updates', ->      
      @backboneClient.update(id: {attribute: 'value'})
      expect(@processUpdatesStub).toHaveBeenCalledWith(id: {attribute: 'value'})
      
  describe '#create', ->
    it 'marks the created models as synced'
        





