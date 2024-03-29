describe 'Versioning', ->
  beforeEach ->
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
      expect(@model._versioning?.vector[@model.clientId]).toBeUndefined()
      @model.initVersioning()
      expect(@model._versioning?.vector[@model.clientId]).toBeDefined()

    it 'retains the local clock if it is already set', ->
      vector = {}
      vector[@model.clientId] = 1
      @model._versioning = {vector: vector}
      @model.initVersioning()
      expect(@model._versioning?.vector[@model.clientId]).toEqual(1)

    it 'sets the createdAt attribute when undefined', ->
      expect(@model._versioning?.createdAt).toBeUndefined()
      @model.initVersioning()
      expect(@model._versioning?.createdAt).toBeDefined()

    it 'retains the createdAt attribute when defined', ->
      @model._versioning = {}
      @model._versioning.createdAt = 'created_at'
      @model.initVersioning()
      expect(@model._versioning?.createdAt).toEqual('created_at')

  describe '#createdAt', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      @model = new TestModel Factory.build('model')

    it 'is undefined when no versioning is present', ->
      expect(@model.createdAt()).toBeUndefined()

    it 'returns the createdAt value stored on the versioning object', ->
      @model._versioning = {}
      @model._versioning.createdAt = 'created_at'
      expect(@model.createdAt()).toEqual('created_at')

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

    it 'sets the versioning createdAt to the value provided', ->
      @model.setVersion({}, 'created_at')
      expect(@model.createdAt()).toEqual('created_at')

    it 'sets the versioning updatedAt to the value provided', ->
      @model.setVersion({}, null, 'updated_at')
      expect(@model.updatedAt()).toEqual('updated_at')

    it 'sets the model vector clock to the newly generated clock', ->
      @model.setVersion(@version)
      expect(@model._versioning.vector).toEqual(@vector)

  describe '#addVersion', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      @model = new TestModel
      @model.localClock = -> 2
      @initVersioningSpy = sinon.spy(@model, 'initVersioning')
      @tickVersionStub = sinon.stub(@model, '_tickVersion')

    it 'initializes versioning', ->
      @model.addVersion()
      expect(@initVersioningSpy).toHaveBeenCalled()

    it 'initializes a list of patches', ->
      expect(@model._versioning?.patches).toBeUndefined()
      @model.addVersion()
      expect(@model._versioning?.patches.constructor.name).toEqual("Array")

    it 'updates the model\'s version', ->
      @model.addVersion()
      expect(@tickVersionStub).toHaveBeenCalled()

    context 'when the skipPatch option is set', ->
      it 'does not save a patch', ->
        @model._versioning = {}
        @model._versioning.patches = []
        @model.addVersion({}, skipPatch: true)
        expect(@model._versioning.patches.length).toEqual(0)

      it 'does not update the model\'s version', ->
        @model.addVersion({}, skipPatch: true)
        expect(@tickVersionStub).not.toHaveBeenCalled()

    context 'when a structured content diff is used for versioning', ->
      beforeEach ->
        class TestModel extends Backbone.Model
          versioning: 'structured_content_diff'
        @model = new TestModel
        @tickVersionStub = sinon.stub(@model, '_tickVersion')
        @patch = sinon.stub()
        @createPatchStub = sinon.stub(@model, '_createPatch', =>
          @patch
        )

      it 'creates a patch providing it with the model\'s local clock', ->
        @model.addVersion()
        expect(@createPatchStub).toHaveBeenCalledWith(@model.localClock())

      it 'saves a patch for the update to _versioning.patches', ->
        @model.addVersion()
        expect(@model._versioning.patches[0]).toEqual @patch

      it 'updates the model\'s version after the patch has been created', ->
        @model.addVersion()
        expect(@tickVersionStub).toHaveBeenCalledAfter(@createPatchStub)

    context 'when a per attribute diff is used for versioning', ->
      beforeEach ->
        @patcher =
          updatePatches: ->
        @updatePatchesStub = sinon.stub(@patcher, 'updatePatches')
        @newPatcherStub = sinon.stub(window,
                                     'Patcher',
                                     => @patcher)

      afterEach ->
        @newPatcherStub.restore()

      it 'creates a new patcher object', ->
        @model.addVersion()
        expect(@newPatcherStub).toHaveBeenCalledWith(@model)

      it 'updates the model patches', ->
        @model.addVersion()
        expect(@updatePatchesStub).toHaveBeenCalled()

      it 'updates the model version after the patch has been created', ->
        @model.addVersion()
        expect(@tickVersionStub).toHaveBeenCalledAfter(@updatePatchesStub)

  describe '#localClock', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      @model = new TestModel
      vector = {}
      vector[@model.clientId] = 1
      @model._versioning = {vector: vector}

    it 'returns the local clock of the model\'s version', ->
      expect(@model.localClock()).toEqual(1)

  describe '#_createPatch', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      @model = new TestModel Factory.build('answer')
      @previousAttributesStub = sinon.stub(@model, 'previousAttributes',
                                           -> 'previous_attributes')
      @model.attributes = 'attributes'
      @sortPropertiesInStub = sinon.stub(@model, '_sortPropertiesIn')
      @sortPropertiesInStub.withArgs('previous_attributes').
                            returns('sorted_previous')
      @sortPropertiesInStub.withArgs('attributes').
                            returns('sorted_attributes')
      dmp =
        diff_main: ->
        patch_make: ->
        patch_toText: ->
      @diffStub        = sinon.stub(dmp, 'diff_main',    -> 'some_diff')
      @patchStub       = sinon.stub(dmp, 'patch_make',   -> 'some_patch')
      @patchToTextStub = sinon.stub(dmp, 'patch_toText', -> 'patch_text')
      @dmpStub         = sinon.stub(window, 'diff_match_patch', -> dmp)
      @stringifyStub   = sinon.stub(JSON, 'stringify', (input) -> input)

    afterEach ->
      @dmpStub.restore()
      @stringifyStub.restore()

    it 'sorts the model previous attributes', ->
      @model._createPatch()
      expect(@sortPropertiesInStub).
        toHaveBeenCalledWith('previous_attributes')

    it 'sorts the model attributes', ->
      @model._createPatch()
      expect(@sortPropertiesInStub).
        toHaveBeenCalledWith('attributes')

    it 'creates a diff of the previous attributes with the attributes', ->
      @model._createPatch()
      expect(@diffStub).toHaveBeenCalledWith('sorted_previous',
                                             'sorted_attributes')

    it 'creates a patch of the diff based on the previous attributes', ->
      @model._createPatch()
      expect(@patchStub).toHaveBeenCalledWith('sorted_previous',
                                              'some_diff')

    it 'sets the text representation of the patch', ->
      expect(@model._createPatch().patch_text).toEqual('patch_text')

    it 'sets the model current version as patch base', ->
      out = @model._createPatch('local_clock')
      expect(out.base).toEqual('local_clock')

  describe '#_sortPropertiesIn', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      @model = new TestModel

    it 'creates a clone with sorted attributes', ->
      object =
        last: 'value'
        first: 'value'
      ordered = @model._sortPropertiesIn(object)
      expect(_.properties(ordered)[0]).toEqual('first')

    it 'sorts the attributes of nested objects', ->
      object =
        nested:
          last: 'value'
          first: 'value'
      ordered = @model._sortPropertiesIn(object)
      expect(_.properties(ordered.nested)[0]).toEqual('first')

  describe '#_tickVersion', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      @model = new TestModel
      vector = {}
      vector[@model.clientId] = 1
      @model._versioning = {vector: vector}

    it 'increments the version for the current model', ->
      @oldVersion = @model._versioning.vector[@model.clientId]
      @model._tickVersion()
      expect(@model._versioning.vector[@model.clientId]).
        toEqual(@oldVersion + 1)

    it 'overwrites updatedAt', ->
      date = new Date(2012, 4, 15, 15, 25, 36)
      clock = sinon.useFakeTimers(date.getTime())
      @model._versioning.updatedAt = 'updated_at'
      @model._tickVersion()
      clock.restore()
      expect(@model._versioning.updatedAt).toEqual(date.toJSON())

  describe '#updatedAt', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      @model = new TestModel Factory.build('model')

    it 'returns the updatedAt value of the versioning object', ->
      @model._versioning = {}
      @model._versioning.updatedAt = 'updated_at'
      expect(@model.updatedAt()).toEqual('updated_at')

    it 'returns the createdAt value when no updatedAt is defined', ->
      @model._versioning = {}
      @model._versioning.createdAt = 'created_at'
      expect(@model.updatedAt()).toEqual('created_at')

  describe '#patches', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      @model = new TestModel
      @patches = sinon.stub()
      @model._versioning =
        patches: @patches

    it 'returns the model patches', ->
      expect(@model.patches()).toEqual(@patches)

  describe '#hasPatches', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      @model = new TestModel Factory.build('model')

    context 'when the model has no versioning', ->
      it 'returns false', ->
        expect(@model.hasPatches()).toBeFalsy()

    context 'when the model has no patches', ->
      beforeEach ->
        @model._versioning = {patches: []}

      it 'returns false', ->
        expect(@model.hasPatches()).toBeFalsy()

    context 'when the model has patches', ->
      beforeEach ->
        @model._versioning = {patches: [{}]}

      it 'returns true', ->
        expect(@model.hasPatches()).toBeTruthy()

  describe '#syncingVersions', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      @model = new TestModel
      @model._versioning =
        syncingVersions: @syncingVersions = sinon.stub()

    it 'returns the versions the model is currently syncing', ->
      expect(@model.syncingVersions()).toEqual(@syncingVersions)

    context 'when there are no versions being synced', ->
      beforeEach ->
        @model._versioning = {}

      it 'returns an empty array', ->
        expect(@model.syncingVersions()).toEqual([])

  describe '#markAsSynced', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      @model = new TestModel
      @model._versioning = {}

    it 'sets the synced property on the versioning object to true', ->
      @model.markAsSynced()
      expect(@model._versioning.synced).toBeTruthy()

  describe '#updateSyncingVersions', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      @model = new TestModel
      @model._versioning = {}
      @localClockStub = sinon.stub(@model, 'localClock', -> 'current_version')

    it 'initializes the syncingVersions array', ->
      expect(@model._versioning.syncingVersions).toBeUndefined()
      @model.updateSyncingVersions()
      expect(@model._versioning.syncingVersions).toBeDefined()

    it 'adds the model version to the list of synced versions', ->
      @model.updateSyncingVersions()
      expect(@model._versioning.syncingVersions[0]).toEqual('current_version')

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
      @methodStub = sinon.stub(@model, 'method', -> 'method_output')

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

    it 'returns the method\'s return value', ->
      expect(@model.processCreate
        remote_version: 'version'
      ).toEqual('method_output')

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
        patches: patches
      @remoteVersion = sinon.stub()
      @finishedSyncingStub = sinon.stub(@model, '_finishedSyncing')
      @patchesShiftSpy = sinon.spy(@model._versioning.patches, 'shift')
      @modelSaveStub = sinon.stub(@model, 'save')

    it 'removes all patches older than the version provided', ->
      vector = {}
      vector[@model.clientId] = 1
      @model._forwardTo(remote_version: vector)
      expect(@model._versioning.patches[0]).toEqual
        patch_text: 'other_patch'
        base: 1

    it 'finishes syncing the version', ->
      @model._forwardTo(remote_version: @remoteVersion)
      @expect(@finishedSyncingStub).toHaveBeenCalledWith(@remoteVersion)

    it 'finishes syncing after removing all old patches', ->
      vector = {}
      vector[@model.clientId] = 1
      @model._forwardTo(remote_version: vector)
      expect(@patchesShiftSpy).not.toHaveBeenCalledAfter(@finishedSyncingStub)

    it 'saves the model', ->
      @model._forwardTo(remote_version: {})
      expect(@modelSaveStub).toHaveBeenCalled()

    it 'saves the model after forwarding it', ->
      @model._forwardTo(remote_version: {})
      expect(@modelSaveStub).toHaveBeenCalledAfter(@finishedSyncingStub)

    it 'returns null', ->
      expect(@model._forwardTo(remote_version: {})).toBeNull()

  describe '#_finishedSyncing', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      @model = new TestModel
      @model._versioning =
        syncingVersions: [1, 2, 1, 3]

    it 'removes all entries smaller than or equal to 
        the local clock from the versions being synced', ->
      vector = {}
      vector[@model.clientId] = 2
      @model._finishedSyncing(vector)
      expect(@model._versioning.syncingVersions).toEqual([3])

  describe '#_changeId', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      @model = new TestModel

    # it 'returns the model', ->
    #   expect(@model._changeId()).toEqual(@model)

  describe '#processUpdate', ->
    beforeEach ->
      class TestModel extends Backbone.Model
        method: ->
      @model = new TestModel
      @updateMethodStub = sinon.stub(@model, '_updateMethod', -> 'method')
      @methodStub = sinon.stub(@model, 'method', -> 'method_output')

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

    it 'returns the method\'s return value', ->
      expect(@model.processUpdate
        remote_version: 'version'
      ).toEqual('method_output')

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
      @applyPatchesToStub = sinon.stub(@model, '_applyPatchesTo', -> true)
      @patches = sinon.stub
      @model._versioning = {patches: @patches}
      @dummy = new TestModel
      @forwardToStub = sinon.stub(@model, '_forwardTo')
      @extractVersioningSpy = sinon.spy(@model, '_extractVersioning')
      @newModelStub = sinon.stub(TestModel::, 'constructor', => @dummy)
      @dummySetStub = sinon.stub(@dummy, 'set')
      @modelSetStub = sinon.stub(@model, 'set')
      @updateVersionToStub = sinon.stub(@model, '_updateVersionTo')
      @modelSaveStub = sinon.stub(@model, 'save')

    afterEach ->
      @newModelStub.restore()

    it 'forwards the model to the remote version', ->
      attributes = sinon.stub()
      @model._rebase attributes
      expect(@forwardToStub).toHaveBeenCalledWith(attributes)

    it 'forwards the model before extracting versioning attributes', ->
      attributes = sinon.stub()
      @model._rebase attributes
      expect(@forwardToStub).toHaveBeenCalledBefore(@extractVersioningSpy)

    it 'extracts the versioning attributes', ->
      attributes =
        attribute: 'value'
        remote_version: 'version'
      @model._rebase attributes
      expect(@extractVersioningSpy).toHaveBeenCalledWith(attributes)

    it 'creates a dummy model', ->
      @model._rebase({})
      expect(@newModelStub).toHaveBeenCalled()

    it 'sets the new attributes on this dummy model', ->
      attributes = sinon.stub()
      @model._rebase(attributes)
      expect(@dummySetStub).toHaveBeenCalledWith(attributes)

    it 'filters out the versioning attributes before setting them', ->
      attributes =
        attribute: 'value'
        remote_version: 'version'
      @model._rebase(attributes)
      expect(@extractVersioningSpy).toHaveBeenCalledBefore(@dummySetStub)

    it 'applies all patches to the dummy model', ->
      @model._rebase({})
      expect(@applyPatchesToStub).toHaveBeenCalledWith(@dummy)

    context 'when all patches are successfully applied', ->
      it 'sets the dummy\'s attributes on the model without creating a patch', ->
        @model._rebase({})
        expect(@modelSetStub).toHaveBeenCalledWith(@dummy, skipPatch: true)

      it 'updates the model version to the remote_version', ->
        attributes =
          attribute: 'value'
          remote_version: 'version',
          updated_at: 'updated_at'
        @model._rebase(attributes)
        expect(@updateVersionToStub).toHaveBeenCalledWith('version', 'updated_at')

      it 'saves the rebased model to the localStorage after that', ->
        @model._rebase({})
        expect(@modelSaveStub).toHaveBeenCalledAfter(@updateVersionToStub)

      it 'returns the updated model', ->
        expect(@model._rebase({})).toEqual(@model)

    context 'when not all patches were applied successfully', ->
      beforeEach ->
        @applyPatchesToStub.restore()
        @applyPatchesToStub = sinon.stub(@model, '_applyPatchesTo', -> false)

      it 'returns null', ->
        expect(@model._rebase({})).toBeNull()

      it 'filters out the attributes that differ'

      it 'creates a diff for each attribute'

  describe '#_extractVersioning', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      @model = new TestModel
      @attributes =
        remote_version: 'remote_version'
        created_at: 'created_at'
        updated_at: 'updated_at'

    it 'removes remote_version from the attributes', ->
      @model._extractVersioning(@attributes)
      expect(@attributes.remote_version).toBeUndefined()

    it 'returns the remote_version', ->
      [version, b, c] = @model._extractVersioning(@attributes)
      expect(version).toEqual('remote_version')

    it 'removes created_at from the attributes', ->
      @model._extractVersioning(@attributes)
      expect(@attributes.created_at).toBeUndefined()

    it 'returns created_at', ->
      [a, created_at, c] = @model._extractVersioning(@attributes)
      expect(created_at).toEqual('created_at')

    it 'removes updated_at from the attributes', ->
      @model._extractVersioning(@attributes)
      expect(@attributes.updated_at).toBeUndefined()

    it 'returns updated_at', ->
      [a, b, updated_at] = @model._extractVersioning(@attributes)
      expect(updated_at).toEqual('updated_at')

  describe '#_applyPatchesTo', ->
    beforeEach ->

    context 'when a structured content diff is used for versioning', ->
      beforeEach ->
        class TestModel extends Backbone.Model
          versioning: 'structured_content_diff'
        @model = new TestModel
        @dummy = new TestModel
        @applyPatchStub = sinon.stub(@dummy, '_applyPatch', ->
          @results ||= [true, true]
          @results.pop()
        )
        @model._versioning = {}
        @model._versioning.patches = [{patch_text: 'some'},
                                      {patch_text: 'patches'}]

      it 'applies each patch to the dummy', ->
        @model._applyPatchesTo(@dummy)
        expect(@applyPatchStub).toHaveBeenCalledWith('some')
        expect(@applyPatchStub).toHaveBeenCalledWith('patches')

      it 'returns true when all patches apply successfully', ->
        expect(@model._applyPatchesTo(@dummy)).toBeTruthy()

      context 'when at least one patch did not apply successfully', ->
        beforeEach ->
          @applyPatchStub.restore()
          @applyPatchStub = sinon.stub(@dummy, '_applyPatch', ->
            @results ||= [true, false, true]
            @results.pop()
          )

        it 'returns false', ->
          expect(@model._applyPatchesTo(@dummy)).toBeFalsy()

    context 'when a per attribute diff is used for versioning', ->
      beforeEach ->
        class TestModel extends Backbone.Model
        @model = new TestModel
        @dummy = new TestModel
        @patcher =
          applyPatchesTo: ->
        @applyPatchesToStub = sinon.stub(@patcher, 'applyPatchesTo',
                                         -> 'patcher_result')
        @newPatcherStub = sinon.stub(window,
                                     'Patcher',
                                     => @patcher)

      afterEach ->
        @newPatcherStub.restore()

      it 'creates a new patcher instance', ->
        @model._applyPatchesTo(@dummy)
        expect(@newPatcherStub).toHaveBeenCalledWith(@model)

      it 'calls the patcher applyPatchesTo method', ->
        @model._applyPatchesTo(@dummy)
        expect(@applyPatchesToStub).
          toHaveBeenCalledWith(@dummy)

      it 'propagates the applyPatchesTo return value', ->
        expect(@model._applyPatchesTo(@dummy)).toEqual('patcher_result')

  describe '#_applyPatch', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      @model = new TestModel
      @model.attributes = 'modelAttributes'
      @dmp = new diff_match_patch
      @dmpStub = sinon.stub(window, 'diff_match_patch', => @dmp)
      @patch = sinon.stub()
      @patchFromTextStub = sinon.stub(@dmp, 'patch_fromText', => @patch)
      @sortPropertiesStub = sinon.stub(@model, '_sortPropertiesIn', -> 'sortedProperties')
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

    it 'sorts the model attributes recursively', ->
      @model._applyPatch()
      expect(@sortPropertiesStub).toHaveBeenCalledWith('modelAttributes')

    it 'converts the sorted attributes to json', ->
      @model._applyPatch()
      expect(@stringifyStub).toHaveBeenCalledWith('sortedProperties')

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
        @patchApplyStub = sinon.stub(@dmp, 'patch_apply', => [@new_json, [true, false]])

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

    it 'sets the versioning updatedAt to the new value', ->
      @model._updateVersionTo({}, 'updated_at')
      expect(@model.updatedAt()).toEqual('updated_at')

    it 'updates each clock with a remote value if the local value is lower', ->
      @model._updateVersionTo({some_unique_id: 4}, 'updated_at')
      expect(@model._versioning.vector).toEqual(some_unique_id: 4)

    it 'adds a remote clock if it did not exist locally', ->
      @model._updateVersionTo({some_other_id: 4}, 'updated_at')
      expect(@model._versioning.vector).toEqual
        some_unique_id: 3
        some_other_id: 4

  describe '#_update', ->
    beforeEach ->
      class TestModel extends Backbone.Model
      @model = new TestModel
      @extractVersioningSpy = sinon.spy(@model, '_extractVersioning')
      @modelSetStub = sinon.stub(@model, 'set')
      @updateVersionToStub = sinon.stub(@model, '_updateVersionTo')
      @modelSaveStub = sinon.stub(@model, 'save')

    it 'extracts the versioning attributes', ->
      attributes =
        attribute: 'value'
        remote_version: 'version'
      @model._update attributes
      expect(@extractVersioningSpy).toHaveBeenCalledWith(attributes)

    it 'sets the updated attributes on the model without creating a patch', ->
      @model._update
        attribute: 'value'
        remote_version: 'version'
      expect(@modelSetStub).toHaveBeenCalledWith({attribute: 'value'}, skipPatch: true)

    it 'filters out the versioning attributes before setting them', ->
      attributes =
        attribute: 'value'
        remote_version: 'version'
      @model._update(attributes)
      expect(@extractVersioningSpy).toHaveBeenCalledBefore(@modelSetStub)

    it 'updates the model version to the remote_version', ->
      @model._update
        attribute: 'value'
        remote_version: 'version'
        updated_at: 'updated_at'
      expect(@updateVersionToStub).toHaveBeenCalledWith('version', 'updated_at')

    it 'saves the rebased model to the localStorage after that', ->
      @model._update({})
      expect(@modelSaveStub).toHaveBeenCalledAfter(@updateVersionToStub)

    it 'returns null', ->
      expect(@model._update({})).toBeNull()

