describe 'versioning', ->

  context 'when a model is saved without an id', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      class TestCollection extends Backbone.Collection
        model: TestModel
      @collection = new TestCollection  
      @model = new TestModel
      @initVersioningSpy = sinon.spy(@model, 'initVersioning')
      @tickVersionSpy = sinon.spy(@model, '_tickVersion')
      @collection.add @model
      @model.save()
      @updatePatchesSpy = sinon.spy(Patcher::, 'updatePatches')

    afterEach -> 
      @updatePatchesSpy.restore()
      @collection.leave()
      @collection._cleanup()

    it 'adds versioning to it', ->
      expect(@initVersioningSpy).toHaveBeenCalled()
      
    it 'can be found within the model', ->
      expect(@collection.get(@model)).toEqual(@model)

    it 'adds a patch', ->
      expect(@model.hasPatches()).toBeTruthy()
      
    it 'updates the model\'s version', ->
      expect(@tickVersionSpy).toHaveBeenCalled()

    context 'and it changes', ->
      beforeEach ->
        @tickVersionSpy.reset()
        @model.set Factory.build('answer')

      it 'updates the patches', ->
        expect(@updatePatchesSpy).toHaveBeenCalled()
        
      it 'updates the version hash', ->
        expect(@tickVersionSpy).toHaveBeenCalled()

  context 'when a model is saved with an id', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      class TestCollection extends Backbone.Collection
        model: TestModel
      @collection = new TestCollection  
      @model = new TestModel Factory.build('answer')
      @initVersioningSpy = sinon.spy(@model, 'initVersioning')
      @tickVersionSpy = sinon.spy(@model, '_tickVersion')
      @collection.add @model
      @model.save()

    afterEach ->
      @collection.leave()
      @collection._cleanup()

    it 'adds versioning to it', ->
      expect(@initVersioningSpy).toHaveBeenCalled()

    it 'does not add a patch', ->
      expect(@model.hasPatches()).toBeFalsy()
      
    it 'does not update the model\'s version', ->
      expect(@tickVersionSpy).not.toHaveBeenCalled()







