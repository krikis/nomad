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
      @patch_text = sinon.stub
      @model._versioning = {patches: _([@patch_text])}
      @dummy = new TestModel
      @newModelStub = sinon.stub(TestModel::, 'constructor', => @dummy)
      @dummySetStub = sinon.stub(@dummy, 'set')
      @processPatchesStub = sinon.stub(@dummy, 'processPatches', -> true)
      @modelSetStub = sinon.stub(@model, 'set')

    afterEach ->
      @newModelStub.restore()

    it 'creates a dummy model', ->
      @model.rebase()
      expect(@newModelStub).toHaveBeenCalled()

    it 'sets the new attributes on this dummy model', ->
      attributes = sinon.stub()
      @model.rebase(attributes)
      expect(@dummySetStub).toHaveBeenCalledWith(attributes)

    it 'applies all patches to the dummy model', ->
      @model.rebase()
      expect(@processPatchesStub).toHaveBeenCalledWith(@model._versioning.patches)
      
    it 'sets the dummy\'s attributes on the model on success', ->
      @model.rebase()
      expect(@modelSetStub).toHaveBeenCalledWith(@dummy)
      
  describe '#processPatches', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      @model = new TestModel
      @applyPatchStub = sinon.stub(@model, 'applyPatch', -> 
        @results ||= [true, true]
        @results.pop()
      )
      
    it 'applies each patch to the model', ->
      @model.processPatches(_(['some', 'patches']))
      expect(@applyPatchStub).toHaveBeenCalledWith('some')
      expect(@applyPatchStub).toHaveBeenCalledWith('patches')
      
    it 'returns true when all patches apply successfully', ->
      expect(@model.processPatches(_(['some', 'patches']))).toBeTruthy()
      
    context 'when at least one patch did not apply successfully', ->
      beforeEach -> 
        @applyPatchStub.restore()
        @applyPatchStub = sinon.stub(@model, 'applyPatch', -> 
          @results ||= [true, false, true]
          @results.pop()
        )
      
      it 'returns false when at least one patch was unsuccessful', ->
        expect(@model.processPatches(_(['some', 'more', 'patches']))).toBeFalsy()

  describe '#applyPatch', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      @model = new TestModel
      @dmp = new diff_match_patch
      @dmpStub = sinon.stub(window, 'diff_match_patch', => @dmp)
      @patch = sinon.stub()
      @patchFromTextStub = sinon.stub(@dmp, 'patch_fromText', => @patch)
      @json = sinon.stub()
      @stringifyStub = sinon.stub(JSON, 'stringify', => @json)
      @new_json = sinon.stub()
      @patchApplyStub = sinon.stub(@dmp, 'patch_apply', => [@new_json, [true]])
      @patched_attributes = sinon.stub()
      @parseStub = sinon.stub(JSON, 'parse', => @patched_attributes)
      @modelSetStub = sinon.stub(@model, 'set')

    afterEach ->
      @dmpStub.restore()
      @patchFromTextStub.restore()
      @stringifyStub.restore()
      @patchApplyStub.restore()
      @parseStub.restore()

    it 'converts the patch_text to a patch', ->
      patch_text = sinon.stub()
      @model.applyPatch(patch_text)
      expect(@patchFromTextStub).toHaveBeenCalledWith(patch_text)

    it 'converts the model object to json', ->
      @model.applyPatch()
      expect(@stringifyStub).toHaveBeenCalledWith(@model)

    it 'applies the patch to the json', ->
      @model.applyPatch()
      expect(@patchApplyStub).toHaveBeenCalledWith(@patch, @json)

    context 'when patching was successfull', ->
      it 'parses new attributes from the new model json', ->
        @model.applyPatch()
        expect(@parseStub).toHaveBeenCalledWith(@new_json)

      it 'updates the model with the patched attributes', ->
        @model.applyPatch()
        expect(@modelSetStub).toHaveBeenCalledWith(@patched_attributes)

      it 'returns true', ->
        expect(@model.applyPatch()).toBeTruthy()

    context 'when patching fails', ->
      beforeEach ->
        @patchApplyStub.restore()
        @patchApplyStub = sinon.stub(@dmp, 'patch_apply', => [@new_json, [false]])

      afterEach ->
        @patchApplyStub.restore()

      it 'returns false', ->
        expect(@model.applyPatch()).toBeFalsy()



    context 'when successfully patched', ->

      it 'sets the new attributes to the original model', ->

      it 'clears the patches of the original model', ->

      it 'sets the original model\'s oldVersion to its version', ->

      it 'calls setVersion on the original model', ->

      it 'publishes the updated model to the server', ->

    context 'when patching fails', ->

      it 'filters out the attributes that differ', ->

      it 'creates a diff for each attribute', ->



