describe 'Patcher', ->

  describe '.new', ->
    beforeEach ->
      @model = sinon.stub()

    it 'sets the model to manage the patches for', ->
      patcher = new Patcher(@model)
      expect(patcher.model).toEqual(@model)

  describe '#updatePatches', ->
    beforeEach ->
      @base               = sinon.stub()
      @changedAttributes  = sinon.stub()
      @previousAttributes = sinon.stub()
      @patches = []
      @model =
        patches: => @patches
        localClock: => @base
        changedAttributes: => @changedAttributes
        previousAttributes: => @previousAttributes
      @patcher = new Patcher(@model)
      @cleanupPatchesStub = sinon.stub(@patcher, '_cleanupPatches')
      @patch = {}
      @createPatchForStub = sinon.stub(@patcher,
                                       '_createPatchFor',
                                       => @patch)
                                       
    it 'cleans up the model patches', ->
      @patcher.updatePatches()
      expect(@cleanupPatchesStub).toHaveBeenCalled()

    it 'calls the _createPatchFor method', ->
      @patcher.updatePatches()
      expect(@createPatchForStub).
        toHaveBeenCalledWith(@changedAttributes,
                             @previousAttributes)

    it 'appends the patch to the list of patches', ->
      @patcher.updatePatches()
      expect(@model.patches()[0]).toEqual
        _patch: @patch
        base: @base
        
  describe '#_cleanupPatches', ->
    beforeEach ->
      @patches = [
        @first = {base: 1}
        @second = {base: 2}
        @last = {base: 3}
      ]
      @model =
        patches: => @patches
        syncingVersions: ->
      @patcher = new Patcher(@model)
          
    it 'retains the first patch', ->
      @patcher._cleanupPatches()
      expect(@model.patches()).toEqual([@first])
      
    context 'when there are versions currently being synced', ->
      beforeEach -> 
        @model.syncingVersions = -> [2]
        
      it 'retains all patches based on these versions', ->
        @patcher._cleanupPatches()
        expect(@model.patches()).toEqual([@first, @second])
      
  describe '#_createPatchFor', ->
    beforeEach ->
      @changedAttributes =
        number: 1234.5
        text: 'some_text'
      @previousAttributes =
        number: 1001.1
        text: 'previous_text'
      @patcher = new Patcher(sinon.stub())

    it 'saves all keys of no-text attributes', ->
      patch = @patcher._createPatchFor(@changedAttributes,
                                       @previousAttributes)
      expect(_.keys(patch)).toContain('number')

    it 'retains the previous version of all text attributes', ->
      patch = @patcher._createPatchFor(@changedAttributes,
                                       @previousAttributes)
      expect(patch.text).toEqual('previous_text')

    context 'when the changed attributes contain an object', ->
      beforeEach ->
        @changedAttributes =
          object:
            number: 1234.5
            text: 'some_text'
        @createPatchForSpy = sinon.spy(@patcher, '_createPatchFor')

      it 'recursively updates the patch for this object', ->
        patch = @patcher._createPatchFor(@changedAttributes,
                                         @previousAttributes)
        expect(@createPatchForSpy).
          toHaveBeenCalledWith(number: 1234.5, text: 'some_text', undefined)

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
      @createPatchForStub = sinon.stub(Patcher::,
                                       '_createPatchFor',
                                       -> 'new_patch')
      @patcher = new Patcher

    afterEach ->
      @createPatchForStub.restore()

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
      @createPatchForStub = sinon.stub(Patcher::,
                                       '_createPatchFor',
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
      @createPatchForStub.restore()
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




