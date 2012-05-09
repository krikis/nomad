describe 'Versioning', ->
  beforeEach ->
    window.localStorage.clear()
    @server = sinon.fakeServer.create()

  afterEach ->
    @server.restore()
    
    
  describe 'initialize', ->
    beforeEach ->
      TestModel = Backbone.Model.extend()
      # stub before creation because of callback binding
      @addPatchStub = sinon.stub Backbone.Model::, "addPatch"
      @model = new TestModel Factory.build("answer")

    afterEach ->
      @addPatchStub.restore()
      
    it 'binds #addPatch to the model change event', ->
      @model.trigger 'change'
      expect(@addPatchStub).toHaveBeenCalled()
      
  describe '#createPatch', ->
    beforeEach ->
      TestModel = Backbone.Model.extend()
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
      TestModel = Backbone.Model.extend()
      @model = new TestModel Factory.build("answer")
      @model.collection = 
        url: "/collection" # stub the model's collection url
      @createPatchSpy = sinon.spy(@model, 'createPatch')
      
    afterEach ->
      @createPatchSpy.restore()
            
    describe '#when the object was synced to the server', ->
      it 'initializes _patches as an empty array', ->
        expect(@model._patches).toBeUndefined()
        @model.save(synced: true)
        expect(@model._patches).toBeDefined()
        expect(@model._patches._wrapped).toBeDefined()
        expect(@model._patches._wrapped.constructor.name).toEqual("Array")
      
      it 'saves a patch for the update', ->
        @model.set(
          synced: true
          values:
            v_1: "other_value_1"
            v_2: "value_2"
        )
        @model.save()
        expect(@model._patches.first()).toEqual @createPatchSpy.returnValues[0]