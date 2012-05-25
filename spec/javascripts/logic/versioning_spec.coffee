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
    
      afterEach ->
        @changedStub.restore()
  
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
        
        
        