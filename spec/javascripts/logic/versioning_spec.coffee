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

    it 'initializes the vector clock if undefined', ->
      expect(@model._versioning?.vector).toBeUndefined()
      @model.initVersioning()
      expect(@model._versioning?.vector).toBeDefined()

    it 'initializes the local clock to zero if undefined', ->
      expect(@model._versioning?.vector[Nomad.clientId]).toBeUndefined()
      @model.initVersioning()
      expect(@model._versioning?.vector[Nomad.clientId]).toBeDefined()

    it 'retains the local clock if it is already set', ->
      vector = {}
      vector[Nomad.clientId] = 1
      @model._versioning = {vector: vector}
      @model.initVersioning()
      expect(@model._versioning?.vector[Nomad.clientId]).toEqual(1)

  describe '#version', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      @model = new TestModel Factory.build('model')
      @vector = sinon.stub()
      @model._versioning = {vector: @vector}

    it 'fetches the vector clock of the versioning object', ->
      expect(@model.version()).toEqual(@vector)
      
  describe '#setVersion', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      @model = new TestModel Factory.build('model')
      @version = sinon.stub()
      @vector = sinon.stub()
      @vectorClockStub = sinon.stub(window, 'VectorClock', => @vector)
    
    afterEach ->
      @vectorClockStub.restore()
      
    it 'initializes a new vector clock for the version provided', ->
      @model.setVersion(@version)
      expect(@vectorClockStub).toHaveBeenCalledWith(@version)
      
    it 'initializes versioning if undefined', ->
      expect(@model._versioning).toBeUndefined()
      @model.setVersion(@version)
      expect(@model._versioning).toBeDefined()
      
    it 'sets the model vector clock to the newly generated clock', ->
      @model.setVersion(@version)
      expect(@model._versioning.vector).toEqual(@vector)

  describe '#addPatch', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      @model = new TestModel
      @model._localClock = -> 2
      @initVersioningSpy = sinon.spy(@model, 'initVersioning')
      @tickVersionStub = sinon.stub(@model, '_tickVersion')
      @patch = sinon.stub()
      @createPatchStub = sinon.stub(@model, '_createPatch', =>
        @patch
      )

    afterEach ->
      @initVersioningSpy.restore()
      @tickVersionStub.restore()
      @createPatchStub.restore()

    it 'initializes _versioning', ->
      @model.addPatch()
      expect(@initVersioningSpy).toHaveBeenCalled()

    it 'initializes _versioning.patches as an empty array', ->
      expect(@model._versioning?.patches).toBeUndefined()
      @model.addPatch()
      expect(@model._versioning?.patches).toBeDefined()
      expect(@model._versioning?.patches._wrapped).toBeDefined()
      expect(@model._versioning?.patches._wrapped.constructor.name).toEqual("Array")

    it 'creates a patch providing it with the model\'s local clock', ->
      @model.addPatch()
      expect(@createPatchStub).toHaveBeenCalledWith(@model._localClock())

    it 'saves a patch for the update to _versioning.patches', ->
      @model.addPatch()
      expect(@model._versioning.patches.first()).toEqual @patch

    it 'updates the model\'s version', ->
      @model.addPatch()
      expect(@tickVersionStub).toHaveBeenCalled()

    it 'updates the model\'s version after the patch has been created', ->
      @model.addPatch()
      expect(@tickVersionStub).toHaveBeenCalledAfter(@createPatchStub)

  describe '#_localClock', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      @model = new TestModel
      vector = {}
      vector[Nomad.clientId] = 1
      @model._versioning = {vector: vector}

    it 'returns the local clock of the model\'s version', ->
      expect(@model._localClock()).toEqual(1)

  describe '#_createPatch', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      @model = new TestModel Factory.build('answer')

    it 'creates a patch for the new model version', ->
      @model.attributes.values =
        v_1: "other_value_1"
        v_2: "value_2"
      out = @model._createPatch()
      expect(out.patch_text).toContain 'other_'
      expect(out.patch_text).not.toContain 'value_2'

    it 'sets the model\'s current version on the newly created patch', ->
      @model.attributes.values =
        v_1: "other_value_1"
        v_2: "value_2"
      out = @model._createPatch('local_clock')
      expect(out.base).toEqual('local_clock')

  describe '#_tickVersion', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      @model = new TestModel
      vector = {}
      vector[Nomad.clientId] = 1
      @model._versioning = {vector: vector}

    it 'increments the version for the current model', ->
      @oldVersion = @model._versioning.vector[Nomad.clientId]
      @model._tickVersion()
      expect(@model._versioning.vector[Nomad.clientId]).toEqual(@oldVersion + 1)

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

  describe '#markAsSynced', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      @model = new TestModel
      @model._versioning = {}

    it 'sets the synced property on the versioning object to true', ->
      @model.markAsSynced()
      expect(@model._versioning.synced).toBeTruthy()

  describe '#isSynced', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      @model = new TestModel Factory.build('model')

    it 'returns whether the model has been synced yet', ->
      @model._versioning = {synced: true}
      expect(@model.isSynced()).toBeTruthy()
      
  describe '#processCreate', ->
    beforeEach ->
      class TestModel extends Backbone.Model
        method: ->
      @model = new TestModel
      @createMethodStub = sinon.stub(@model, '_createMethod', -> 'method')
      @methodStub = sinon.stub(@model, 'method')    
      
    it 'derives the create method', ->
      @model.processCreate
        attribute: 'value'
        remote_version: 'version'
      expect(@createMethodStub).toHaveBeenCalledWith('version')

    it 'calls the method returned', ->
      @model.processCreate
        attribute: 'value'
        remote_version: 'version'
      expect(@methodStub).toHaveBeenCalledWith
        attribute: 'value'
        remote_version: 'version'
      
  describe '#_createMethod', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      @model = new TestModel

    it 'checks the version of the update', ->
      @checkVersionStub = sinon.stub(@model, '_checkVersion')
      @model._createMethod 'version'
      expect(@checkVersionStub).toHaveBeenCalledWith('version')

    it 'returns the _forwardTo method when client supersedes server', ->
      @checkVersionStub = sinon.stub(@model, '_checkVersion', -> 'supersedes')
      expect(@model._createMethod()).toEqual('_forwardTo')

    it 'returns the _changeId method when client conflicts with server', ->
      @checkVersionStub = sinon.stub(@model, '_checkVersion', -> 'conflictsWith')
      expect(@model._createMethod()).toEqual('_changeId')

    it 'returns the _changeId method when client precedes server', ->
      @checkVersionStub = sinon.stub(@model, '_checkVersion', -> 'precedes')
      expect(@model._createMethod()).toEqual('_changeId')
        
  describe '#_checkVersion', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      @model = new TestModel
      @version = new VectorClock
      @model.version = => @version
      
    context 'when the versions equal', ->  
      beforeEach ->
        @equalsStub = sinon.stub(@version, 'equals', -> true)
    
      it 'returns supersedes', ->
        expect(@model._checkVersion({})).toEqual('supersedes')

    context 'when the model version supersedes the server version', ->  
      beforeEach ->
        @equalsStub = sinon.stub(@version, 'equals', -> false)
        @supersedesStub = sinon.stub(@version, 'supersedes', -> true)
    
      it 'returns supersedes', ->
        expect(@model._checkVersion({})).toEqual('supersedes')

    context 'when the model version conflicts with the server version', ->  
      beforeEach ->
        @equalsStub = sinon.stub(@version, 'equals', -> false)
        @supersedesStub = sinon.stub(@version, 'supersedes', -> false)
        @conflictsWithStub = sinon.stub(@version, 'conflictsWith', -> true)
    
      it 'returns conflictsWith', ->
        expect(@model._checkVersion({})).toEqual('conflictsWith')

    context 'when the client version precedes the server version', ->  
      beforeEach ->
        @equalsStub = sinon.stub(@version, 'equals', -> false)
        @supersedesStub = sinon.stub(@version, 'supersedes', -> false)
        @conflictsWithStub = sinon.stub(@version, 'conflictsWith', -> false)
    
      it 'returns precedes', ->
        expect(@model._checkVersion({})).toEqual('precedes')

  describe '#_forwardTo', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      @model = new TestModel
      patches = [{patch_text: 'some_patch',  base: 0},
                 {patch_text: 'other_patch', base: 1}]
      @model._versioning =
        patches: _(patches)
      @patchesShiftSpy = sinon.spy(@model._versioning.patches, 'shift')
      @modelSaveStub = sinon.stub(@model, 'save')

    it 'removes all patches older than the version provided', ->
      vector = {}
      vector[Nomad.clientId] = 1
      @model._forwardTo(remote_version: vector)
      expect(@model._versioning.patches.first()).toEqual
        patch_text: 'other_patch'
        base: 1
    
    it 'saves the model', -> 
      @model._forwardTo(remote_version: {})
      expect(@modelSaveStub).toHaveBeenCalled()
    
    it 'saves the model after forwarding it', ->  
      @model._forwardTo(remote_version: {})
      expect(@patchesShiftSpy).not.toHaveBeenCalledAfter(@modelSaveStub)
      
  describe '#processUpdate', ->
    beforeEach ->
      class TestModel extends Backbone.Model
        method: ->
      @model = new TestModel
      @updateMethodStub = sinon.stub(@model, '_updateMethod', -> 'method')
      @methodStub = sinon.stub(@model, 'method')
    
    it 'derives the update method', ->
      @model.processUpdate
        attribute: 'value'
        remote_version: 'version'
      expect(@updateMethodStub).toHaveBeenCalledWith('version')
      
    it 'calls the method returned', ->
      @model.processUpdate
        attribute: 'value'
        remote_version: 'version'
      expect(@methodStub).toHaveBeenCalledWith
        attribute: 'value'
        remote_version: 'version'
        
  describe '#_updateMethod', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      @model = new TestModel
      
    it 'checks the version of the update', ->
      @checkVersionStub = sinon.stub(@model, '_checkVersion')
      @model._updateMethod 'version'
      expect(@checkVersionStub).toHaveBeenCalledWith('version')
      
    it 'returns the _forwardTo method when client supersedes server', ->
      @checkVersionStub = sinon.stub(@model, '_checkVersion', -> 'supersedes')
      expect(@model._updateMethod()).toEqual('_forwardTo')
      
    it 'returns the _rebase method when client conflicts with server', ->
      @checkVersionStub = sinon.stub(@model, '_checkVersion', -> 'conflictsWith')
      expect(@model._updateMethod()).toEqual('_rebase')
      
    it 'returns the _update method when client precedes server', ->
      @checkVersionStub = sinon.stub(@model, '_checkVersion', -> 'precedes')
      expect(@model._updateMethod()).toEqual('_update')   

  describe '#_rebase', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      @model = new TestModel Factory.build('answer')
      @patches = sinon.stub
      @model._versioning = {patches: @patches}
      @dummy = new TestModel
      @newModelStub = sinon.stub(TestModel::, 'constructor', => @dummy)
      @dummySetStub = sinon.stub(@dummy, 'set')
      @processPatchesStub = sinon.stub(@dummy, '_processPatches', -> true)
      @modelSetStub = sinon.stub(@model, 'set')
      @updateVersionToStub = sinon.stub(@model, '_updateVersionTo')
      @modelSaveStub = sinon.stub(@model, 'save')

    afterEach ->
      @newModelStub.restore()

    it 'creates a dummy model', ->
      @model._rebase({})
      expect(@newModelStub).toHaveBeenCalled()

    it 'sets the new attributes on this dummy model', ->
      attributes = sinon.stub()
      @model._rebase(attributes)
      expect(@dummySetStub).toHaveBeenCalledWith(attributes)

    it 'filters out the remote_version before doing so', ->
      attributes =
        attribute: 'value'
        remote_version: 'version'
      @model._rebase(attributes)
      expect(@dummySetStub).toHaveBeenCalledWith(attribute: 'value')

    it 'applies all patches to the dummy model', ->
      @model._rebase({})
      expect(@processPatchesStub).toHaveBeenCalledWith(@patches)

    context 'when all patches are successfully applied', ->
      it 'sets the dummy\'s attributes on the model', ->
        @model._rebase({})
        expect(@modelSetStub).toHaveBeenCalledWith(@dummy)

      it 'updates the model version to the remote_version', ->
        attributes =
          attribute: 'value'
          remote_version: 'version'
        @model._rebase(attributes)
        expect(@updateVersionToStub).toHaveBeenCalledWith('version')
        
      it 'saves the rebased model to the localStorage after that', ->
        @model._rebase({})
        expect(@modelSaveStub).toHaveBeenCalledAfter(@updateVersionToStub)

      it 'returns the updated model', ->
        expect(@model._rebase({})).toEqual(@model)

    context 'when not all patches were applied successfully', ->
      beforeEach ->
        @processPatchesStub.restore()
        @processPatchesStub = sinon.stub(@dummy, '_processPatches', -> false)

      it 'returns false', ->
        expect(@model._rebase({})).toBeFalsy()

      it 'filters out the attributes that differ'

      it 'creates a diff for each attribute'

  describe '#_processPatches', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      @model = new TestModel
      @applyPatchStub = sinon.stub(@model, '_applyPatch', ->
        @results ||= [true, true]
        @results.pop()
      )

    it 'applies each patch to the model', ->
      @model._processPatches(_([{patch_text: 'some'},
                               {patch_text: 'patches'}]))
      expect(@applyPatchStub).toHaveBeenCalledWith('some')
      expect(@applyPatchStub).toHaveBeenCalledWith('patches')

    it 'returns true when all patches apply successfully', ->
      expect(@model._processPatches(_(['some', 'patches']))).toBeTruthy()

    context 'when at least one patch did not apply successfully', ->
      beforeEach ->
        @applyPatchStub.restore()
        @applyPatchStub = sinon.stub(@model, '_applyPatch', ->
          @results ||= [true, false, true]
          @results.pop()
        )

      it 'returns false when at least one patch was unsuccessful', ->
        expect(@model._processPatches(_(['some', 'more', 'patches']))).toBeFalsy()

  describe '#_applyPatch', ->
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
      @model._applyPatch(patch_text)
      expect(@patchFromTextStub).toHaveBeenCalledWith(patch_text)

    it 'converts the model object to json', ->
      @model._applyPatch()
      expect(@stringifyStub).toHaveBeenCalledWith(@model)

    it 'applies the patch to the json', ->
      @model._applyPatch()
      expect(@patchApplyStub).toHaveBeenCalledWith(@patch, @json)

    context 'when patching was successfull', ->
      it 'parses new attributes from the new model json', ->
        @model._applyPatch()
        expect(@parseStub).toHaveBeenCalledWith(@new_json)

      it 'updates the model with the patched attributes', ->
        @model._applyPatch()
        expect(@modelSetStub).toHaveBeenCalledWith(@patched_attributes)

      it 'returns true', ->
        expect(@model._applyPatch()).toBeTruthy()

    context 'when patching fails', ->
      beforeEach ->
        @patchApplyStub.restore()
        @patchApplyStub = sinon.stub(@dmp, 'patch_apply', => [@new_json, [false]])

      afterEach ->
        @patchApplyStub.restore()

      it 'returns false', ->
        expect(@model._applyPatch()).toBeFalsy()

  describe '#_updateVersionTo', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      @model = new TestModel
      @model._versioning =
        vector: 
          some_unique_id: 3

    it 'updates each clock with a remote value if the local value is lower', ->
      @model._updateVersionTo(some_unique_id: 4)
      expect(@model._versioning.vector).toEqual(some_unique_id: 4)  

    it 'adds a remote clock if it did not exist locally', ->
      @model._updateVersionTo(some_other_id: 4)
      expect(@model._versioning.vector).toEqual
        some_unique_id: 3
        some_other_id: 4

  describe '#_update', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      @model = new TestModel
      @modelSetStub = sinon.stub(@model, 'set')
      @updateVersionToStub = sinon.stub(@model, '_updateVersionTo')
      @modelSaveStub = sinon.stub(@model, 'save')
      
    it 'sets the updated attributes on the model, except for the remote_version', ->
      @model._update
        attribute: 'value'
        remote_version: 'version'
      expect(@modelSetStub).toHaveBeenCalledWith(attribute: 'value')  

    it 'updates the model version to the remote_version', ->
      @model._update
        attribute: 'value'
        remote_version: 'version'
      expect(@updateVersionToStub).toHaveBeenCalledWith('version')  
        
    it 'saves the rebased model to the localStorage after that', ->
      @model._update({})
      expect(@modelSaveStub).toHaveBeenCalledAfter(@updateVersionToStub)
    
