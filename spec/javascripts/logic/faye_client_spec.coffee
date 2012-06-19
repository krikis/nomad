describe 'FayeClient', ->
  beforeEach ->
    fayeClient = {}
    fayeClient.subscribe = ->
    fayeClient.unsubscribe = ->
    fayeClient.publish = ->
    @subscribeStub = sinon.stub(fayeClient, 'subscribe')
    @unsubscribeStub = sinon.stub(fayeClient, 'unsubscribe')
    @publishStub = sinon.stub(fayeClient, 'publish')
    @clientConstructorStub = sinon.stub(Faye, 'Client')
    @clientConstructorStub.returns fayeClient
    @collection = new Backbone.Collection([], modelName: 'TestModel')
    @modelName = 'TestModel'
    Nomad.clientId = 'some_unique_id'

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
      
    it 'initializes the subscriptions array', ->
      expect(@backboneClient.subscriptions).toEqual([])

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
      expect(@publishStub).
        toHaveBeenCalledWith('/server/' + @modelName, message)

  describe '#subscribe', ->
    beforeEach ->
      @backboneClient = new BackboneSync.FayeClient @collection,
                                                    modelName: @modelName

    it 'subscribes the wrapped client to the channel', ->
      expect(@subscribeStub).
        toHaveBeenCalledWith('/sync/TestModel',
                             @backboneClient.receive,
                             @backboneClient)

    it 'subscribes the wrapped client to a personal channel', ->
      expect(@subscribeStub).
          toHaveBeenCalledWith('/sync/TestModel/some_unique_id',
                               @backboneClient.receive,
                               @backboneClient)
                               
    it 'collects the subscriptions', ->
      expect(@backboneClient.subscriptions).
        toEqual(['/sync/TestModel', '/sync/TestModel/some_unique_id'])
        
  describe '#unsubscribe', ->
    beforeEach ->
      @backboneClient = new BackboneSync.FayeClient @collection,
                                                    modelName: @modelName
                                                    
    it 'unsubscribes the wrapped client from all recorded channels', ->
      @backboneClient.subscriptions = ['some_subscription', 'other_subscription']
      @backboneClient.unsubscribe()
      expect(@unsubscribeStub).toHaveBeenCalledWith('some_subscription')
      expect(@unsubscribeStub).toHaveBeenCalledWith('other_subscription')
      
    it 'unsubscribes from a specific channel if provided', ->  
      @backboneClient.subscriptions = ['some_channel', 'other_channel']
      @backboneClient.unsubscribe('some_channel')
      expect(@unsubscribeStub).toHaveBeenCalledWith('some_channel')
      expect(@backboneClient.subscriptions).toEqual(['other_channel'])

  describe '#receive', ->
    beforeEach ->
      @syncModelsStub = sinon.stub(@collection, 'syncModels')
      @syncProcessedStub = sinon.stub(@collection, 'syncProcessed')
      @backboneClient = new BackboneSync.FayeClient @collection,
                                                modelName: @modelName
      @backboneClient.meta = sinon.stub()
      @backboneClient.method_1 = ->
      @backboneClient.method_2 = ->
      @method1Stub = sinon.stub(@backboneClient, 'method_1')
      @method2Stub = sinon.stub(@backboneClient, 'method_2')
      
    it 'calls a method for each actual entry in the message', ->
      @backboneClient.receive
        meta:
          meta: 'information'
        method_1: 'params'
        method_2: 'other_params'
      expect(@backboneClient.meta).not.toHaveBeenCalled()
      expect(@method1Stub).
        toHaveBeenCalledWith('params', {})
      expect(@method2Stub).
        toHaveBeenCalledWith('other_params', {})

    context 'when the message concerns presync feedback', ->
      beforeEach ->
        @message =
          meta:
            preSync: true
          method_1: 'params'
            
      it 'syncs all dirty models to the server', ->
        @backboneClient.receive @message
        expect(@syncModelsStub).toHaveBeenCalled()
        
      it 'syncs all dirty models after processing the message', ->
        @backboneClient.receive @message
        expect(@syncModelsStub).
          toHaveBeenCalledAfter(@backboneClient.method_1)

    context 'when the message does not concern presync feedback', ->
      beforeEach ->
        @method1Stub.restore()
        @method1Stub = sinon.stub(@backboneClient, 'method_1', (params, processed) ->
          processed.creates = ['resolved']
        )
        @method2Stub.restore()
        @method2Stub = sinon.stub(@backboneClient, 'method_2', (params, processed) ->
          processed.updates = ['rebased']
        )
        @message =
          method_1: 'params'
          method_2: 'params'

      it 'syncs all processed models to the server', ->
        @backboneClient.receive(@message)
        expect(@syncProcessedStub).
          toHaveBeenCalledWith
            creates: ['resolved']
            updates: ['rebased']
        
      it 'does not sync all dirty models to the server', ->
        @backboneClient.receive(@message)
        expect(@syncModelsStub).not.toHaveBeenCalled()
      
  describe '#create', ->
    beforeEach ->
      @handleCreatesStub = sinon.
        stub(@collection, 'handleCreates', -> ['other_creates'])
      @backboneClient = new BackboneSync.FayeClient @collection,
                                                    modelName: @modelName
                                                        
    context 'when creates are present', ->
      beforeEach ->
        @creates = 
          id: 'attributes'
                                                        
      it 'has the collection process the creates', ->
        @backboneClient.create(@creates, {})
        expect(@handleCreatesStub).toHaveBeenCalledWith({id: 'attributes'})
        
      it 'appends the handleCreates output for sync', ->
        processed = {creates: ['creates']}
        @backboneClient.create(@creates, processed)
        expect(processed).toEqual(creates: ['creates', 'other_creates'])

    context 'when no creates are present', ->      
      it 'does not invoke the collection method', ->
        @backboneClient.create({}, {})
        expect(@handleCreatesStub).not.toHaveBeenCalled()

  describe '#update', ->
    beforeEach ->
      @handleUpdatesStub = sinon.
        stub(@collection, 'handleUpdates', -> ['other_updates'])
      @backboneClient = new BackboneSync.FayeClient @collection,
                                                    modelName: @modelName

    context 'when updates are present', ->
      beforeEach ->
        @updates =
          id: 'updates'
      it 'has the collection process the updates', ->
        @backboneClient.update(@updates, {})
        expect(@handleUpdatesStub).toHaveBeenCalledWith({id: 'updates'})
        
      it 'appends the handleUpdates output for sync', ->
        processed = {updates: ['updates']}
        @backboneClient.update(@updates, processed)
        expect(processed).toEqual(updates: ['updates', 'other_updates'])
      
    context 'when no updates are present', ->
      it 'does not invoke the collection method', ->
        @backboneClient.update({}, {})
        expect(@handleUpdatesStub).not.toHaveBeenCalled()
        
      






