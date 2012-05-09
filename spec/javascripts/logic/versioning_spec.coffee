describe 'Versioning', ->
  beforeEach ->
    window.localStorage.clear()
    
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
      
  describe '#addPatch', ->  
    beforeEach ->
      TestModel = Backbone.Model.extend()
      @model = new TestModel Factory.build("answer")
      @model.collection = 
        url: "/collection" # stub the model's collection url
      @server = sinon.fakeServer.create()

    afterEach ->
      @server.restore()
            
    describe '#when the object was synced to the server', ->
      it 'initializes _patches as an empty array', ->
        expect(@model._patches).toBeUndefined()
        @model.save(synced: true)
        expect(@model._patches).toBeDefined()
        expect(@model._patches._wrapped).toBeDefined()
        expect(@model._patches._wrapped.constructor.name).toEqual("Array")
      
      it 'saves a patch for the update', ->
        @model.set values:
          v_1: "other_value_1"
          v_2: "value_2"
        @model.save()
        # expect(@model._patches.first()).toContain "other_value_1"