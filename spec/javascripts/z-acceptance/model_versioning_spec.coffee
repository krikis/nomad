describe 'modelVersioning', ->
  
  beforeEach ->
    # delete faye client created during isolated tests
    unless window.acceptance_client?
      delete window.client
      window.acceptance_client = true

  context 'when a model is saved without an id', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      class TestCollection extends Backbone.Collection
        model: TestModel
      @model = new TestModel
      @collection = new TestCollection
      @collection.add @model
      @model.save()

    it 'adds versioning to it', ->
      expect(@model._versioning).toBeDefined()

    it 'adds an oldVersion hash to it', ->
      expect(@model._versioning?.oldVersion).toBeDefined()

    it 'adds a version hash to it', ->
      expect(@model._versioning?.version).toBeDefined()
      
    it 'can be found within the model', ->
      expect(@collection.get(@model)).toEqual(@model)

    context 'and it changed but was never synced', ->
      beforeEach ->
        @setVersionStub = sinon.stub(@model, 'setVersion')
        @model.set Factory.build('answer')

      it 'does not add a patch', ->
        expect(@model.hasPatches()).toBeFalsy()
        
      it 'updates the version hash', ->
        expect(@setVersionStub).toHaveBeenCalled()

    context 'and it changed after it has been synced', ->
      beforeEach ->
        @model._versioning =
          synced: true
        @setVersionStub = sinon.stub(@model, 'setVersion')
        @model.set Factory.build('answer')

      it 'adds a patch', ->
        expect(@model.hasPatches()).toBeTruthy()
        
      it 'updates the version hash', ->
        expect(@setVersionStub).toHaveBeenCalled()

  context 'when a model is saved with an id', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      class TestCollection extends Backbone.Collection
        model: TestModel
      @model = new TestModel Factory.build('answer')
      @collection = new TestCollection
      @collection.add @model
      @model.save()

    it 'adds versioning to it', ->
      expect(@model._versioning).toBeDefined()

    it 'adds an oldVersion hash to it', ->
      expect(@model._versioning?.oldVersion).toBeDefined()

    it 'does not add a version hash to it', ->
      expect(@model._versioning?.version).toBeUndefined()







