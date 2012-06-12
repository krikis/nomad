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
                                                    modelName: @modelName

    afterEach ->
      @backboneClientStub.restore()

    it 'fires up the Faye client', ->
      expect(@clientConstructorStub).toHaveBeenCalled()

    it 'sets the collection and modelName property', ->
      expect(@backboneClient.collection).toEqual @collection
      expect(@backboneClient.modelName).toEqual @modelName

    it 'calls the subscribe method', ->
      expect(@backboneClientStub).toHaveBeenCalled()

    it 'does not fire up a new Faye client if one is already running', ->
      @otherClient = new BackboneSync.FayeClient @collection,
                                                 modelName: @modelName
      expect(@clientConstructorStub).toHaveBeenCalledOnce()

  describe '#publish', ->
    beforeEach ->
      @backboneClient = new BackboneSync.FayeClient @collection,
                                                    modelName: @modelName

    it 'adds the Nomad client id to the message', ->
      message = {}
      @backboneClient.publish(message)
      expect(message.client_id).toEqual(Nomad.clientId)

    it 'adds the model name to the message', ->
      message = {}
      @backboneClient.publish(message)
      expect(message.model_name).toEqual(@backboneClient.modelName)

    it 'preserves client_id if it is already set', ->
      message = {client_id: 'preset_id'}
      @backboneClient.publish(message)
      expect(message.client_id).toEqual('preset_id')

    it 'preserves model_name if it is already set', ->
      message = {model_name: 'preset_name'}
      @backboneClient.publish(message)
      expect(message.model_name).toEqual('preset_name')

    it 'calls the publish method on the faye client object', ->
      message = sinon.stub()
      @backboneClient.publish message
      expect(@fayeClientStub.publish).
        toHaveBeenCalledWith('/server/' + @modelName, message)

  describe '#subscribe', ->
    beforeEach ->
      @backboneClient = new BackboneSync.FayeClient @collection,
                                                    modelName: @modelName

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
      @syncModelsStub = sinon.stub(@collection, 'syncModels')
      @backboneClient = new BackboneSync.FayeClient @collection,
                                                modelName: @modelName
      @backboneClient.meta = sinon.stub()
      @backboneClient.method_1 = sinon.stub()
      @backboneClient.method_2 = sinon.stub()
      
    it 'calls a method for each actual entry in the message', ->
      @backboneClient.receive
        meta:
          meta: 'information'
        method_1:
          id: {attribute_1: 'test'}
        method_2:
          id: {attribute_2: 'receive'}
      expect(@backboneClient.meta).not.toHaveBeenCalled()
      expect(@backboneClient.method_1).
        toHaveBeenCalledWith(id: {attribute_1: 'test'})
      expect(@backboneClient.method_2).
        toHaveBeenCalledWith(id: {attribute_2: 'receive'})

    it 'has the collection sync models to the server after that 
        when it concerns presync feedback', ->
      @backboneClient.receive
        meta:
          preSync: true
        method_1:
          id: {attribute_1: 'test'}
      expect(@syncModelsStub).toHaveBeenCalled()
      expect(@syncModelsStub).toHaveBeenCalledAfter(@backboneClient.method_1)

    it 'does not sync models to the server when it is no presync feedback', ->
      @backboneClient.receive({})
      expect(@syncModelsStub).not.toHaveBeenCalled()
      
  describe '#create', ->
    

  describe '#update', ->
    beforeEach ->
      @handleUpdatesStub = sinon.stub(@collection, 'handleUpdates')
      @backboneClient = new BackboneSync.FayeClient @collection,
                                                    modelName: @modelName

    afterEach ->
      @handleUpdatesStub.restore()

    it 'has the collection process the updates', ->
      @backboneClient.update(id: {attribute: 'value'})
      expect(@handleUpdatesStub).toHaveBeenCalledWith(id: {attribute: 'value'})
      






