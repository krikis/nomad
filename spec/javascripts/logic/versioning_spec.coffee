describe 'Versioning', ->
  beforeEach ->
    window.localStorage.clear()
    @server = sinon.fakeServer.create()

  afterEach ->
    @server.restore()
    
  describe '#initVersioning', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      @model = new TestModel Factory.build("model")
    
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
      @model = new TestModel Factory.build("answer")

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
      @initVersioningSpy = sinon.spy(Backbone.Model::, 'initVersioning')
      class TestModel extends Backbone.Model
      @model = new TestModel Factory.build("answer")
      @model.collection =
        url: "/collection" # stub the model's collection url
      @createPatchSpy = sinon.spy(@model, 'createPatch')

    afterEach ->
      @createPatchSpy.restore()
      @initVersioningSpy.restore()

    it 'initializes _versioning', ->
      @model.save(synced: true)
      expect(@initVersioningSpy).toHaveBeenCalled()

    context 'once the object is synced to the server', ->
      it 'initializes _versioning.patches as an empty array', ->
        expect(@model._versioning?.patches).toBeUndefined()
        @model.save(synced: true)
        expect(@model._versioning?.patches).toBeDefined()
        expect(@model._versioning?.patches._wrapped).toBeDefined()
        expect(@model._versioning?.patches._wrapped.constructor.name).toEqual("Array")

      it 'saves a patch for the update to _versioning.patches', ->
        @model.set(
          synced: true
          values:
            v_1: "other_value_1"
            v_2: "value_2"
        )
        @model.save()
        expect(@model._versioning.patches.first()).toEqual @createPatchSpy.returnValues[0]

  describe '#createPatch', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      @model = new TestModel Factory.build("answer", synced: true)
      @model.collection =
        url: "/collection" # stub the model's collection url
      @createPatchSpy = sinon.spy(@model, 'createPatch')

    afterEach ->
      @createPatchSpy.restore()

    it 'creates a patch for the new model version', ->
      @model.set  values:
        v_1: "other_value_1"
        v_2: "value_2"
      @model.save()
      expect(@createPatchSpy).toHaveBeenCalled()
      patch = @createPatchSpy.returnValues[0]
      expect(patch).toContain 'other_'
      expect(patch).not.toContain 'value_2'
        
        
        