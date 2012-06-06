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
      @backboneClient = new BackboneSync.FayeClient @collection,
                                                modelName: @modelName
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
      @syncModelsStub = sinon.stub(@collection, 'syncModels')
      @backboneClient = new BackboneSync.FayeClient @collection,
                                                    modelName: @modelName

    afterEach ->
      @processUpdatesStub.restore()

    it 'has the collection process the updates', ->
      @backboneClient.update(id: {attribute: 'value'})
      expect(@processUpdatesStub).toHaveBeenCalledWith(id: {attribute: 'value'})
      
    it 'has the collection sync models to the server after that 
        when it concerns presync feedback', ->
      @backboneClient.update(preSync: true)
      expect(@syncModelsStub).toHaveBeenCalledAfter(@processUpdatesStub)
      
    it 'does not sync models to the server when it is no presync feedback', ->
      @backboneClient.update({})
      expect(@syncModelsStub).not.toHaveBeenCalled()
      
  describe '#ack', ->
    beforeEach ->
      @model = new Backbone.Model
      @forwardToStub = sinon.stub(@model, 'forwardTo')
      @backboneClient = new BackboneSync.FayeClient @collection,
                                                    modelName: @modelName
    
    it 'forwards the model to the version provided', ->
      @getStub = sinon.stub(@collection, 'get', => @model)
      @backboneClient.ack(some_id: 'some_version')
      expect(@forwardToStub).toHaveBeenCalledWith('some_version')
      
    it 'does not attempt to forward if no model was found', ->
      @getStub = sinon.stub(@collection, 'get')
      @backboneClient.ack(some_id: 'some_version')
      expect(@forwardToStub).not.toHaveBeenCalledWith('some_version')
      






