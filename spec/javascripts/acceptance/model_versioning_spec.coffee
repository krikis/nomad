describe 'modelVersioning', ->
  context 'when a model is created without an id', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      class TestCollection extends Backbone.Collection
        model: TestModel
      @collection = new TestCollection
      @model = @collection.create()

    it 'adds versioning to it', ->
      expect(@model._versioning).toBeDefined()

    it 'adds an oldVersion hash to it', ->
      expect(@model._versioning?.oldVersion).toBeDefined()

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

    context 'and it changed but was never synced', ->
      beforeEach ->
        @model.set Factory.build('answer')

      it 'does not add a patch', ->
        expect(@model.hasPatches()).toBeFalsy()

    context 'and it changed after it has been synced', ->
      beforeEach ->
        @model._versioning =
          synced: true
        @model.set Factory.build('answer')

      it 'adds a patch', ->
        expect(@model.hasPatches()).toBeTruthy()
        
  context 'when a model is created with an id', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      class TestCollection extends Backbone.Collection
        model: TestModel
      @collection = new TestCollection
      @model = @collection.create(Factory.build('answer'))

    it 'does not add versioning to it', ->
      expect(@model._versioning).toBeUndefined()

    context 'and it changed but was never synced', ->
      beforeEach ->
        @model.set
          values:
            v_1: "other_value_1"
            v_2: "value_2"

      it 'adds versioning to it', ->
        expect(@model._versioning).toBeDefined()

      it 'adds an oldVersion hash to it', ->
        expect(@model._versioning?.oldVersion).toBeDefined()

      it 'does not add a patch', ->
        expect(@model.hasPatches()).toBeFalsy()

    context 'and it changed after it has been synced', ->
      beforeEach ->
        @model._versioning =
          synced: true
        @model.set 
          values:
            v_1: "other_value_1"
            v_2: "value_2"

      it 'adds versioning to it', ->
        expect(@model._versioning).toBeDefined()

      it 'adds an oldVersion hash to it', ->
        expect(@model._versioning?.oldVersion).toBeDefined()

      it 'adds a patch', ->
        expect(@model.hasPatches()).toBeTruthy()

  context 'when a model is saved with an id', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      class TestCollection extends Backbone.Collection
        model: TestModel
      @model = new TestModel Factory.build('answer')
      @collection = new TestCollection
      @collection.add @model
      @model.save()

    it 'does not add versioning to it', ->
      expect(@model._versioning).toBeUndefined()

    context 'and it changed but was never synced', ->
      beforeEach ->
        @model.set
          values:
            v_1: "other_value_1"
            v_2: "value_2"

      it 'adds versioning to it', ->
        expect(@model._versioning).toBeDefined()

      it 'adds an oldVersion hash to it', ->
        expect(@model._versioning?.oldVersion).toBeDefined()

      it 'does not add a patch', ->
        expect(@model.hasPatches()).toBeFalsy()

    context 'and it changed after it has been synced', ->
      beforeEach ->
        @model._versioning =
          synced: true
        @model.set 
          values:
            v_1: "other_value_1"
            v_2: "value_2"

      it 'adds versioning to it', ->
        expect(@model._versioning).toBeDefined()

      it 'adds an oldVersion hash to it', ->
        expect(@model._versioning?.oldVersion).toBeDefined()

      it 'adds a patch', ->
        expect(@model.hasPatches()).toBeTruthy()








