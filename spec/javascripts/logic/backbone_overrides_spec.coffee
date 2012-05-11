describe 'Overrides', ->
  
  describe 'Backbone.Model', ->
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
