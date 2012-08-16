describe 'FayeClient', ->
  beforeEach ->
    @fayeClient = {}
    @fayeClient.subscribe = ->
    @fayeClient.unsubscribe = ->
    @fayeClient.publish = ->
    @subscribeStub = sinon.stub(@fayeClient, 'subscribe')
    @unsubscribeStub = sinon.stub(@fayeClient, 'unsubscribe')
    @publishStub = sinon.stub(@fayeClient, 'publish')
    @clientConstructorStub = sinon.stub(Faye, 'Client')
    @clientConstructorStub.returns @fayeClient
    @modelName = 'TestModel'
    @clientId = 'client_id'
    @collection = new Backbone.Collection([], 
      modelName: @modelName
      clientId: @clientId
    )
    delete window.client
    @clientConstructorStub.reset()

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
      @backboneClient = new BackboneSync.FayeClient @collection

    afterEach ->
      @backboneClientStub.restore()
      
    it 'sets the clientId from the options', ->  
      @backboneClient = new BackboneSync.FayeClient @collection,
        clientId: 'some_id'
      expect(@backboneClient.clientId).toEqual('some_id')

    it 'sets the modelName from the options', ->  
      @backboneClient = new BackboneSync.FayeClient @collection,
        modelName: 'model_name'
      expect(@backboneClient.modelName).toEqual('model_name')
      
    context 'when a client option was passed in', ->
      beforeEach ->
        @clientConstructorStub.reset()
        @backboneClient = new BackboneSync.FayeClient @collection,
                                                      client: 'faye_client'
      it 'sets the client property', ->
        expect(@backboneClient.client).toEqual('faye_client')

      it 'does not fire up a new Faye client', ->
        expect(@clientConstructorStub).not.toHaveBeenCalled()

    context 'when no client option was passed in', ->
      it 'fires up a new Faye client', ->
        expect(@clientConstructorStub).toHaveBeenCalled()
      
      it 'sets the client property to the newly created client', ->
        expect(@backboneClient.client).toEqual(@fayeClient)
        
      context 'when a Faye client is already running', ->
        beforeEach ->
          window.client = 'faye_client'
          @clientConstructorStub.reset()
          @backboneClient = new BackboneSync.FayeClient @collection

        it 'does not fire up a new one', ->
          expect(@clientConstructorStub).not.toHaveBeenCalled()

    it 'sets the collection property', ->
      expect(@backboneClient.collection).toEqual @collection
      
    it 'sets the modelName property from the collection', ->
      expect(@backboneClient.modelName).toEqual @modelName
      
    it 'sets the clientId property from the collection', ->
      expect(@backboneClient.clientId).toEqual @clientId
      
    it 'initializes the subscriptions array', ->
      expect(@backboneClient.subscriptions).toEqual([])

    it 'calls the subscribe method', ->
      expect(@backboneClientStub).toHaveBeenCalled()

  describe '#publish', ->
    beforeEach ->
      @backboneClient = new BackboneSync.FayeClient @collection
      @lastSyncedStub = sinon.stub(@collection, 'lastSynced', -> 'timestamp')

    it 'adds the Nomad client id to the message', ->
      message = {}
      @backboneClient.publish(message)
      expect(message.client_id).toEqual(@clientId)

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
      
    it 'adds the lastSynced timestamp to the message', ->
      message = {}
      @backboneClient.publish(message)
      expect(message.last_synced).toEqual('timestamp')

    it 'calls the publish method on the faye client object', ->
      message = sinon.stub()
      @backboneClient.publish message
      expect(@publishStub).
        toHaveBeenCalledWith('/server/' + @modelName, message)

  describe '#subscribe', ->
    beforeEach ->
      @backboneClient = new BackboneSync.FayeClient @collection

    it 'subscribes the wrapped client to the channel', ->
      expect(@subscribeStub).
        toHaveBeenCalledWith('/sync/TestModel',
                             @backboneClient.receive,
                             @backboneClient)

    it 'subscribes the wrapped client to a personal channel', ->
      expect(@subscribeStub).
          toHaveBeenCalledWith('/sync/TestModel/client_id',
                               @backboneClient.receive,
                               @backboneClient)
                               
    it 'collects the subscriptions', ->
      expect(@backboneClient.subscriptions).
        toEqual(['/sync/TestModel', '/sync/TestModel/client_id'])
        
  describe '#unsubscribe', ->
    beforeEach ->
      @backboneClient = new BackboneSync.FayeClient @collection
                                                    
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
      
  describe '#_offline', -> 
    beforeEach ->
      @backboneClient = new BackboneSync.FayeClient sinon.stub()
      
    it 'sets the isOffline flag', ->
      @backboneClient._offline()
      expect(@backboneClient.isOffline).toBeTruthy()
      
  describe '#_online', ->
    beforeEach ->
      @backboneClient = new BackboneSync.FayeClient sinon.stub()
      
    it 'unsets the isOffline flag', ->
      @backboneClient.isOffline = true
      @backboneClient._online()
      expect(@backboneClient.isOffline).toBeFalsy()

  describe '#receive', ->
    beforeEach ->
      @setLastSyncedStub = sinon.stub(@collection, 'setLastSynced')
      @syncModelsStub = sinon.stub(@collection, 'syncModels')
      @syncProcessedStub = sinon.stub(@collection, 'syncProcessed')
      @backboneClient = new BackboneSync.FayeClient @collection
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
        
    it 'updates the collection sync state', ->
      @backboneClient.receive
        meta:
          client: @clientId
          timestamp: 'timestamp'
      expect(@setLastSyncedStub).toHaveBeenCalledWith('timestamp')

    context 'when the message concerns presync feedback', ->
      beforeEach ->
        @message =
          meta:
            preSync: true
          method_1: 'params'
            
      it 'syncs all dirty models to the server', ->
        @backboneClient.receive @message
        expect(@syncModelsStub).toHaveBeenCalledWith(afterPresync: true)
        
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
          meta:
            timestamp: 'timestamp'
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
        
    context 'when the client is offline', ->
      beforeEach ->
        @backboneClient.isOffline = true
        
      it 'does not updates the collection sync state', ->
        @backboneClient.receive
          meta:
            timestamp: 'timestamp'
        expect(@setLastSyncedStub).not.toHaveBeenCalled()    
        
      it 'does not sync all dirty models to the server', ->
        @backboneClient.receive
          meta:
            timestamp: 'timestamp'
        expect(@syncModelsStub).not.toHaveBeenCalled()

      it 'does not sync all processed models to the server', ->
        @backboneClient.receive
          meta:
            timestamp: 'timestamp'
        expect(@syncProcessedStub).not.toHaveBeenCalled()
      
  describe '#create', ->
    beforeEach ->
      @handleCreatesStub = sinon.
        stub(@collection, 'handleCreates', -> ['other_creates'])
      @backboneClient = new BackboneSync.FayeClient @collection
                                                        
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
        
    context 'when the client is offline', ->
      beforeEach ->
        @backboneClient.isOffline = true
        
      it 'does not invoke the collection method', ->
        @backboneClient.create({}, {})
        expect(@handleCreatesStub).not.toHaveBeenCalled()

  describe '#update', ->
    beforeEach ->
      @handleUpdatesStub = sinon.
        stub(@collection, 'handleUpdates', -> ['other_updates'])
      @backboneClient = new BackboneSync.FayeClient @collection

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
        
    context 'when the client is offline', ->
      beforeEach ->
        @backboneClient.isOffline = true
        
      it 'does not invoke the collection method', ->
        @backboneClient.update({}, {})
        expect(@handleUpdatesStub).not.toHaveBeenCalled()
        
      






