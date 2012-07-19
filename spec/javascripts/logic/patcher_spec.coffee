describe 'Patcher', ->

  describe '.new', ->
    beforeEach ->
      @model = sinon.stub()

    it 'sets the model to manage the patches for', ->
      patcher = new Patcher(@model)
      expect(patcher.model).toEqual(@model)

  describe '#updatePatches', ->
    beforeEach ->
      @model =
        patches:            => @patches            ||= []
        localClock:         => @base               ||= sinon.stub()
        changedAttributes:  => @changedAttributes  ||= sinon.stub()
        previousAttributes: => @previousAttributes ||= sinon.stub()
        syncingVersions:    => @syncingVersions    ||= []
      @patcher = new Patcher(@model)
      @updatePatchForStub = sinon.stub(@patcher,
                                       '_updatePatchFor')

    context 'when there are no patches present', ->
      it 'appends a new patch to the list of patches', ->
        @patcher.updatePatches()
        expect(@model.patches()[0]).toEqual
          _patch: {}
          base: @base

      context 'and the local clock is undefined', ->
        beforeEach ->
          @model.localClock = -> undefined

        it 'sets the patch base to zero', ->
          @patcher.updatePatches()
          expect(@model.patches()[0].base).toEqual 0

    context 'when the last patch is currently being synced', ->
      beforeEach ->
        @patches = [
          base: 0
        ]
        @syncingVersions = [0]

      it 'appends a new patch to the list of patches', ->
        @patcher.updatePatches()
        expect(_.last @model.patches()).toEqual
          _patch: {}
          base: @base

    it 'calls the _updatePatchFor method', ->
      @patcher.updatePatches()
      expect(@updatePatchForStub).
        toHaveBeenCalledWith(@changedAttributes,
                             @previousAttributes)

  describe '#_updatePatchFor', ->
    beforeEach ->
      @changedAttributes =
        number: 1234.5
        text: 'some_text'
      @previousAttributes =
        number: 1001.1
        text: 'previous_text'
      @model =
        patches: => @patches ||= sinon.stub()
      @patcher = new Patcher(@model)
      @lastStub = sinon.stub(_, 'last', => @patch ||= {})

    afterEach ->
      @lastStub.restore()

    it 'fechtes the last model patch', ->
      @patcher._updatePatchFor(@changedAttributes,
                               @previousAttributes)
      expect(@lastStub).toHaveBeenCalledWith(@patches)

    it 'saves all keys of no-text attributes', ->
      @patcher._updatePatchFor(@changedAttributes,
                               @previousAttributes)
      expect(_.keys(@patch)).toContain('number')

    it 'retains the previous version of all text attributes', ->
      @patcher._updatePatchFor(@changedAttributes,
                               @previousAttributes)
      expect(@patch.text).toEqual('previous_text')

    context 'when the patch has the attribute already', ->
      beforeEach ->
        @patch =
          text: 'original_text'
          number: 'was_text_previously'

      it 'leaves the patch attribute unchanged', ->
        @patcher._updatePatchFor(@changedAttributes,
                                 @previousAttributes)
        expect(@patch.text).toEqual('original_text')
        expect(@patch.number).toEqual('was_text_previously')

    context 'when the changed attributes contain an object', ->
      beforeEach ->
        @changedAttributes =
          object:
            all: 'attributes'
        @previousAttributes =
          object:
            previous: 'attributes'
        @updatePatchForSpy = sinon.spy(@patcher, '_updatePatchFor')
        @changedAttributesStub = sinon.stub(@patcher, '_changedAttributes', ->
          changed: 'attributes'
        )

      it 'filters out the changed attributes for the object', ->
        @patcher._updatePatchFor(@changedAttributes,
                                 @previousAttributes)
        expect(@changedAttributesStub).
          toHaveBeenCalledWith({all: 'attributes'}, {previous: 'attributes'})

      it 'recursively updates the patch for this object', ->
        @patcher._updatePatchFor(@changedAttributes,
                                 @previousAttributes)
        expect(@updatePatchForSpy).
          toHaveBeenCalledWith({changed: 'attributes'}, 
                               {previous: 'attributes'})

      context 'and the patch already recorded this object', ->
        beforeEach ->
          @patch =
            object: null

        it 'does not recursively update the patch for this object', ->
          @patcher._updatePatchFor(@changedAttributes,
                                   @previousAttributes)
          expect(@updatePatchForSpy).not.toHaveBeenCalledTwice()

  describe '#_changedAttributes', ->
    beforeEach ->
      @patcher = new Patcher
      @attributes =
        changed: 'attribute'
        unchanged: 'attribute'
        created: 'attribute'
      @previousAttributes =
        previous: 'attribute'
        unchanged: 'attribute'
        removed: 'attribute'

    it 'returns all attributes that changed', ->
      changedAttributes = @patcher._changedAttributes(@attributes,
                                                      @previousAttributes)
      expect(changedAttributes.changed).toEqual 'attribute'

    it 'returns all attributes that were removed', ->
      changedAttributes = @patcher._changedAttributes(@attributes,
                                                      @previousAttributes)
      expect(_.has changedAttributes, 'removed').toBeTruthy()
      expect(changedAttributes.removed).toEqual undefined

    it 'returns all attributes that were created', ->
      changedAttributes = @patcher._changedAttributes(@attributes,
                                                      @previousAttributes)
      expect(changedAttributes.created).toEqual 'attribute'

    it 'does not return attributes that were left unchanged', ->
      changedAttributes = @patcher._changedAttributes(@attributes,
                                                      @previousAttributes)
      expect(_.has changedAttributes, 'unchanged').toBeFalsy()

  describe '#applyPatchesTo', ->
    beforeEach ->
      @first =
        _patch: @firstPatch = sinon.stub()
      @last =
        _patch: @lastPatch = sinon.stub()
      @model =
        patches: => [@first, @last]
        attributes: @currentAttributes = sinon.stub()
      @patcher = new Patcher(@model)
      @applyPatchStub = sinon.stub(@patcher, '_applyPatch')
      @dummy =
        attributes: @attributesToPatch = sinon.stub()

    it 'calls _applyPatch', ->
      @patcher.applyPatchesTo(@dummy)
      expect(@applyPatchStub).toHaveBeenCalledWith(@lastPatch,
                                                   @attributesToPatch,
                                                   @firstPatch,
                                                   @currentAttributes)

  describe '#_applyPatch', ->
    beforeEach ->
      @patcher = new Patcher(sinon.stub())
      @patchAttributeStub = sinon.stub(@patcher, '_patchAttribute')
      @firstPatch =
        attribute: @originalValue = sinon.stub()
      @lastPatch =
        attribute: @value = sinon.stub()
      @current =
        attribute: @currentValue = sinon.stub()
      @attributesToPatch = sinon.stub()

    it 'calls the _patchAttribute method for each attribute', ->
      @patcher._applyPatch(@lastPatch, @attributesToPatch,
                           @firstPatch, @current)
      expect(@patchAttributeStub).
        toHaveBeenCalledWith('attribute', @value, @attributesToPatch,
                             @originalValue, @currentValue)

    context 'when all calls for each attribute return true', ->
      beforeEach ->
        @firstPatch.secondAttribute = sinon.stub()
        @lastPatch .secondAttribute = sinon.stub()
        @current   .secondAttribute = sinon.stub()
        @patchAttributeStub.restore()
        @patchAttributeStub = sinon.stub(@patcher, '_patchAttribute', ->
          @out ||= [true, true]
          @out.pop()
        )

      it 'returns true', ->
        expect(
          @patcher._applyPatch(@lastPatch, @attributesToPatch,
                               @firstPatch, @current)
        ).toBeTruthy()

    context 'when at least one call for an attribute returns false', ->
      beforeEach ->
        @firstPatch.secondAttribute = sinon.stub()
        @lastPatch .secondAttribute = sinon.stub()
        @current   .secondAttribute = sinon.stub()
        @patchAttributeStub.restore()
        @patchAttributeStub = sinon.stub(@patcher, '_patchAttribute', ->
          @out ||= [false, true]
          @out.pop()
        )

      it 'returns false', ->
        expect(
          @patcher._applyPatch(@lastPatch, @attributesToPatch,
                               @firstPatch, @current)
        ).toBeFalsy()

  describe '_patchAttribute', ->
    beforeEach ->
      @updatePatchForStub = sinon.stub(Patcher::,
                                       '_updatePatchFor',
                                       -> 'new_patch')
      @patcher = new Patcher

    afterEach ->
      @updatePatchForStub.restore()

    context 'when it concerns a non-text attribute', ->
      beforeEach ->
        @attribute = 'attribute'
        @value = sinon.stub()
        @attributesToPatch = sinon.stub()
        @originalValue = sinon.stub()
        @currentValue = 1234.5

      it 'sets the attribute on the model', ->
        @patcher._patchAttribute(@attribute, @value, @attributesToPatch,
                                 @originalValue, @currentValue)
        expect(@attributesToPatch[@attribute]).toEqual(@currentValue)

      it 'returns true', ->
        expect(
          @patcher._patchAttribute(@attribute, @value, @attributesToPatch,
                                   @originalValue, @currentValue)
        ).toBeTruthy()

    context 'when it concerns an object', ->
      beforeEach ->
        @attribute = 'attribute'
        @value = sinon.stub()
        @attributesToPatch =
          attribute: @objectToPatch =
            object: 'value'
        @originalValue = sinon.stub()
        @currentValue =
          object: 'current_value'
        @applyPatchStub = sinon.stub(@patcher, '_applyPatch')

      it 'recursively calls the _applyPatch method', ->
        @patcher._patchAttribute(@attribute, @value, @attributesToPatch,
                                 @originalValue, @currentValue)
        expect(@applyPatchStub).
          toHaveBeenCalledWith(@value, @objectToPatch,
                               @originalValue, @currentValue)

      context 'and the patch value is not an object', ->
        beforeEach ->
          @value = undefined

        it 'does not go into recursion', ->
          @patcher._patchAttribute(@attribute, @value, @attributesToPatch,
                                   @originalValue, @currentValue)
          expect(@applyPatchStub).not.toHaveBeenCalled()

        it 'sets the attribute to the current value', ->
          @patcher._patchAttribute(@attribute, @value, @attributesToPatch,
                                   @originalValue, @currentValue)
          expect(@attributesToPatch[@attribute]).toEqual(@currentValue)

        it 'returns true', ->
          expect(
            @patcher._patchAttribute(@attribute, @value, @attributesToPatch,
                                     @originalValue, @currentValue)
          ).toBeTruthy()

      context 'and the value to patch is not an object', ->
        beforeEach ->
          @attributesToPatch =
            attribute: @objectToPatch = 'value_to_patch'

        it 'does not go into recursion', ->
          @patcher._patchAttribute(@attribute, @value, @attributesToPatch,
                                   @originalValue, @currentValue)
          expect(@applyPatchStub).not.toHaveBeenCalled()

        it 'sets the attribute to the current value', ->
          @patcher._patchAttribute(@attribute, @value, @attributesToPatch,
                                   @originalValue, @currentValue)
          expect(@attributesToPatch[@attribute]).toEqual(@currentValue)

        it 'returns true', ->
          expect(
            @patcher._patchAttribute(@attribute, @value, @attributesToPatch,
                                     @originalValue, @currentValue)
          ).toBeTruthy()

    context 'when it concerns a text attribute', ->
      beforeEach ->
        @attribute = 'text'
        @value = sinon.stub()
        @attributesToPatch =
          text: 'model_text'
        @originalValue = 'original_text'
        @currentValue = 'current_text'
        @patchStringStub = sinon.stub(@patcher, '_patchString')

      it 'calls the _patchString method', ->
        @patcher._patchAttribute(@attribute, @value, @attributesToPatch,
                                 @originalValue, @currentValue)
        expect(@patchStringStub).
          toHaveBeenCalledWith(@attribute, @attributesToPatch,
                               @originalValue, @currentValue)

      context 'and the original value is not text', ->
        beforeEach ->
          @originalValue = sinon.stub()

        it 'sets the current value on the model', ->
          @patcher._patchAttribute(@attribute, @value, @attributesToPatch,
                                   @originalValue, @currentValue)
          expect(@attributesToPatch.text).toEqual(@currentValue)

        it 'returns true', ->
          expect(
            @patcher._patchAttribute(@attribute, @value, @attributesToPatch,
                                     @originalValue, @currentValue)
          ).toBeTruthy()

  describe '#_patchString', ->
    beforeEach ->
      @updatePatchForStub = sinon.stub(Patcher::,
                                       '_updatePatchFor',
                                       -> 'new_patch')
      @patcher = new Patcher
      @attribute = 'text'
      @attributesToPatch =
        text: 'model_text'
      @originalValue = 'original_text'
      @currentValue = 'current_text'
      @patcher.dmp = @dmp = new diff_match_patch
      @dmpStub        = sinon.stub(window, 'diff_match_patch', => @dmp)
      @diffStub       = sinon.stub(@dmp, 'diff_main', -> 'some_diff')
      @patchStub      = sinon.stub(@dmp, 'patch_make', -> 'some_patch')
      @patchApplyStub = sinon.stub(@dmp, 'patch_apply',
                                   -> ['patched_value', [true]])

    afterEach ->
      @updatePatchForStub.restore()
      @dmpStub.restore()

    it 'generates a diff for the attribute', ->
      @patcher._patchString(@attribute, @attributesToPatch,
                            @originalValue, @currentValue)
      expect(@diffStub).toHaveBeenCalledWith(@originalValue, @currentValue)

    it 'generates a patch for the attribute', ->
      @patcher._patchString(@attribute, @attributesToPatch,
                            @originalValue, @currentValue)
      expect(@patchStub).toHaveBeenCalledWith(@originalValue, 'some_diff')

    it 'applies a patch on the model attribute', ->
      @patcher._patchString(@attribute, @attributesToPatch,
                            @originalValue, @currentValue)
      expect(@patchApplyStub).toHaveBeenCalledWith('some_patch',
                                                   'model_text')

    context 'and patching a text-attribute succeeds', ->
      it 'sets the successfully patched attribute on the model', ->
        @patcher._patchString(@attribute, @attributesToPatch,
                              @originalValue, @currentValue)
        expect(@attributesToPatch.text).toEqual('patched_value')

      it 'returns true', ->
        expect(
          @patcher._patchString(@attribute, @attributesToPatch,
                                @originalValue, @currentValue)
        ).toBeTruthy()

    context 'and patching a text-attribute fails', ->
      beforeEach ->
        @patchApplyStub.restore()
        @patchApplyStub = sinon.stub(@dmp,
                                     'patch_apply',
                                     -> ['patched_value', [false]])

      it 'does not set the patched attribute on the model', ->
        @patcher._patchString(@attribute, @attributesToPatch,
                              @originalValue, @currentValue)
        expect(@attributesToPatch.text).toEqual('model_text')

      it 'returns false', ->
        expect(
          @patcher._patchString(@attribute, @attributesToPatch,
                                @originalValue, @currentValue)
        ).toBeFalsy()

    context 'and original and current value are equal', ->
      beforeEach ->
        @currentValue = @originalValue
        @patchApplyStub.restore()
        @patchApplyStub = sinon.stub(@dmp, 'patch_apply',
                                     -> ['patched_value', []])

      it 'returns true', ->
        expect(
          @patcher._patchString(@attribute, @attributesToPatch,
                                @originalValue, @currentValue)
        ).toBeTruthy()



