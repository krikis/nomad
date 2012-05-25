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
      @model.initVersioning()
      hash = CryptoJS.SHA256(JSON.stringify @model).toString()
      expect(@model._versioning.oldVersion).toEqual(hash)

  describe '#hasPatches', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      @model = new TestModel Factory.build("answer")

    context 'when the model has no patches', ->
      it 'returns false', ->
        expect(@model.hasPatches()).toBeFalsy()

    context 'when the model has patches', ->
      beforeEach ->
        @model._patches = _([{}])

      it 'returns true', ->
        expect(@model.hasPatches()).toBeTruthy()

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

  describe '#addPatch', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      @model = new TestModel Factory.build("answer")
      @model.collection =
        url: "/collection" # stub the model's collection url
      @createPatchSpy = sinon.spy(@model, 'createPatch')

    afterEach ->
      @createPatchSpy.restore()

    context 'when the object was synced to the server', ->
      it 'initializes _patches', ->
        expect(@model._patches).toBeUndefined()
        @model.save(synced: true)
        expect(@model._patches).toBeDefined()
        
      it 'initializes _patches.list as an empty array', ->
        expect(@model._patches?.list).toBeUndefined()
        @model.save(synced: true)
        expect(@model._patches?.list).toBeDefined()
        expect(@model._patches?.list._wrapped).toBeDefined()
        expect(@model._patches?.list._wrapped.constructor.name).toEqual("Array")

      it 'saves a patch for the update to the _patches.list', ->
        @model.set(
          synced: true
          values:
            v_1: "other_value_1"
            v_2: "value_2"
        )
        @model.save()
        expect(@model._patches?.list.first()).toEqual @createPatchSpy.returnValues[0]