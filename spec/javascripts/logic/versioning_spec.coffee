describe 'Versioning', ->
  beforeEach ->
    window.localStorage.clear()
    @server = sinon.fakeServer.create()

  afterEach ->
    @server.restore()
    
  describe '#initVersioning', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      @model = new TestModel Factory.build('model')
    
    it 'initializes the _versioning object if undefined', ->
      expect(@model._versioning).toBeUndefined()
      @model.initVersioning()
      expect(@model._versioning).toBeDefined()
    
    it 'sets the oldVersion property to a hash of the object', ->  
      hash = CryptoJS.SHA256(JSON.stringify @model.previousAttributes()).toString()
      @model.initVersioning()
      expect(@model._versioning.oldVersion).toEqual(hash)

  describe '#hasPatches', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      @model = new TestModel Factory.build('model')

    context 'when the model has no versioning', ->
      it 'returns false', ->
        expect(@model.hasPatches()).toBeFalsy()

    context 'when the model has no patches', ->
      beforeEach ->
        @model._versioning = {patches: _([])}
        
      it 'returns false', ->
        expect(@model.hasPatches()).toBeFalsy()

    context 'when the model has patches', ->
      beforeEach ->
        @model._versioning = {patches: _([{}])}

      it 'returns true', ->
        expect(@model.hasPatches()).toBeTruthy()

  describe '#addPatch', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      @model = new TestModel
      @initVersioningSpy = sinon.spy(@model, 'initVersioning')
      @patch = sinon.stub()
      @createPatchStub = sinon.stub(@model, 'createPatch', =>
        @patch
      )

    afterEach ->  
      @initVersioningSpy.restore()
      @createPatchStub.restore()
      
    it 'initializes _versioning', ->
      @model.addPatch()
      expect(@initVersioningSpy).toHaveBeenCalled()
        
    context 'when the model has changed', ->
      beforeEach ->
        @changedStub = sinon.stub(@model, 'hasChanged', -> true)
        @setVersionStub = sinon.stub(@model, 'setVersion')
    
      afterEach ->
        @changedStub.restore()
        @setVersionStub.restore()
  
      it 'does not add a patch if the model was never synced before', ->
        @model.addPatch()
        expect(@model.hasPatches()).toBeFalsy()
        
      context 'after it was synced to the server', ->
        beforeEach ->
          @model._versioning = 
            synced: true
        
        it 'initializes _versioning.patches as an empty array', ->
          expect(@model._versioning?.patches).toBeUndefined()
          @model.addPatch()
          expect(@model._versioning?.patches).toBeDefined()
          expect(@model._versioning?.patches._wrapped).toBeDefined()
          expect(@model._versioning?.patches._wrapped.constructor.name).toEqual("Array")
  
        it 'saves a patch for the update to _versioning.patches', ->
          @model.addPatch()
          expect(@model._versioning.patches.first()).toEqual @patch
          
          
        it 'calls setVersion on the model', ->
          @model.addPatch()
          expect(@setVersionStub).toHaveBeenCalled()

  describe '#createPatch', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      @model = new TestModel Factory.build('answer')

    it 'creates a patch for the new model version', ->
      @model.attributes.values =
        v_1: "other_value_1"
        v_2: "value_2"
      patch = @model.createPatch()
      expect(patch).toContain 'other_'
      expect(patch).not.toContain 'value_2'
      
  describe '#setVersion', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      @model = new TestModel Factory.build('answer')
      @model._versioning = {}
    
    it 'sets the version for the current model', ->
      @model.setVersion()
      hash = CryptoJS.SHA256(JSON.stringify @model).toString()
      expect(@model._versioning.version).toEqual(hash)
      
    context 'when the version already exists', ->
      beforeEach ->
        @model._versioning = {version: 'some_version'}
        
      it 'overwrites the existing version', ->
        @model.setVersion()
        hash = CryptoJS.SHA256(JSON.stringify @model).toString()
        expect(@model._versioning.version).toEqual(hash)
        
  describe '#rebase', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      @model = new TestModel Factory.build('answer')
      @dummy = new TestModel
      @newModelStub = sinon.stub(TestModel::, 'constructor', -> @dummy)
      
    afterEach ->
      @newModelStub.restore()
        
    it 'creates a dummy model', ->
      @model.rebase()
      expect(@newModelStub).toHaveBeenCalled()
      
    it 'sets the new attributes on this dummy model', ->
      
    it 'applies all patches to the dummy model', ->
      
    context 'when successfully patched', ->
      
      it 'sets the new attributes to the original model', ->
        
      it 'clears the patches of the original model', ->
        
      it 'sets the original model\'s oldVersion to its version', ->
      
      it 'calls setVersion on the original model', ->
        
      it 'publishes the updated model to the server', ->
        
    context 'when patching fails', ->
      
      it 'filters out the attributes that differ', ->
        
      it 'creates a diff for each attribute', ->
        
        
        
        