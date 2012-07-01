describe 'ModelPatch', ->

  describe '.new', ->
    beforeEach ->
      @base               = sinon.stub()
      @changedAttributes  = sinon.stub()
      @previousAttributes = sinon.stub()
      @createPatchForStub = sinon.stub(ModelPatch::,
                                       '_createPatchFor',
                                       -> 'new_patch')

    afterEach ->
      @createPatchForStub.restore()

    it 'sets the patch base', ->
      @modelPatch = new ModelPatch(@base,
                                   @changedAttributes,
                                   @previousAttributes)
      expect(@modelPatch.base).toEqual(@base)

    it 'calls the _createPatchFor method', ->
      @modelPatch = new ModelPatch(@base,
                                   @changedAttributes,
                                   @previousAttributes)
      expect(@createPatchForStub).
        toHaveBeenCalledWith(@changedAttributes,
                             @previousAttributes)

    it 'stores the output in _patch', ->
      @modelPatch = new ModelPatch(@base,
                                   @changedAttributes,
                                   @previousAttributes)
      expect(@modelPatch._patch).toEqual('new_patch')

  describe '#_createPatchFor', ->
    beforeEach ->
      @changedAttributes =
        number: 1234.5
        text: 'some_text'
      @previousAttributes =
        number: 1001.1
        text: 'previous_text'
      @createPatchForStub = sinon.stub(ModelPatch::,
                                       '_createPatchFor',
                                       -> 'new_patch')
      @modelPatch = new ModelPatch(@base,
                                   @changedAttributes,
                                   @previousAttributes)
      @createPatchForStub.restore()

    it 'saves all changed no-text attributes', ->
      patch = @modelPatch._createPatchFor(@changedAttributes,
                                          @previousAttributes)
      expect(patch.number).
        toEqual(@changedAttributes.number)

    it 'retains the previous version of all text attributes', ->
      patch = @modelPatch._createPatchFor(@changedAttributes,
                                          @previousAttributes)
      expect(patch.text).toEqual('previous_text')

    context 'when the changed attributes contain an object', ->
      beforeEach ->
        @changedAttributes =
          object:
            number: 1234.5
            text: 'some_text'
        @updatePatchSpy = sinon.spy(@modelPatch, '_createPatchFor')

      it 'recursively updates the patch for this object', ->
        patch = @modelPatch._createPatchFor(@changedAttributes,
                                            @previousAttributes)
        expect(@updatePatchSpy).
          toHaveBeenCalledWith(number: 1234.5, text: 'some_text', undefined)

  describe '#applyTo', ->
    beforeEach ->
      @createPatchForStub = sinon.stub(ModelPatch::,
                                       '_createPatchFor',
                                       -> 'new_patch')
      @modelPatch = new ModelPatch
      @applyPatchStub = sinon.stub(@modelPatch, '_applyPatch')
      @patch = sinon.stub()
      @modelPatch._patch = @patch
      @model = sinon.stub()
      @firstPatch = sinon.stub()
      @first =
        _patch: @firstPatch
      @current = sinon.stub()

    afterEach ->
      @createPatchForStub.restore()

    it 'calls _applyPatch', ->
      @modelPatch.applyTo(@model, @first, @current)
      expect(@applyPatchStub).toHaveBeenCalledWith(@patch,
                                                   @model,
                                                   @firstPatch,
                                                   @current)

  describe '#_applyPatch', ->
    beforeEach ->
      @createPatchForStub = sinon.stub(ModelPatch::,
                                       '_createPatchFor',
                                       -> 'new_patch')
      @modelPatch = new ModelPatch
      @lastPatch = 
        number: 1234.5
        text: 'base_text'
      @modelPatch._patch = @lastPatch
      @model = new Backbone.Model
        number: 3212.1
        text: 'original_text_and_more'
      @firstPatch =
        number: 1101.1
        text: 'original_text'
      @current =
        number: 1234.5
        text: 'current_text'
      @dmp = new diff_match_patch
      @modelPatch.dmp = @dmp
      @dmpStub = sinon.stub(window, 'diff_match_patch', => @dmp)
      @diffStub = sinon.stub(@dmp, 'diff_main', -> 'some_diff')
      @patchStub = sinon.stub(@dmp, 'patch_make', -> 'some_patch')
      @patchApplyStub = sinon.stub(@dmp, 
                                   'patch_apply', 
                                   -> ['patched_value', [true]])
      @setStub = sinon.stub(@model, 'set')

    afterEach ->
      @createPatchForStub.restore()
      @dmpStub.restore()

    it 'sets the non-text attributes from the patch', ->
      @modelPatch._applyPatch(@lastPatch, @model, @firstPatch, @current)
      expect(@setStub).toHaveBeenCalledWith('number', 1234.5, skipPatch: true)

    it 'generates a diff for text attributes', ->
      @modelPatch._applyPatch(@lastPatch, @model, @firstPatch, @current)
      expect(@diffStub).toHaveBeenCalledWith('original_text', 'current_text')
      
    it 'generates a patch for text attributes', ->
      @modelPatch._applyPatch(@lastPatch, @model, @firstPatch, @current)
      expect(@patchStub).toHaveBeenCalledWith('original_text', 'some_diff')
      
    it 'applies a patch to the model text attribute', ->
      @modelPatch._applyPatch(@lastPatch, @model, @firstPatch, @current)
      expect(@patchApplyStub).toHaveBeenCalledWith('some_patch', 
                                                   'original_text_and_more')
    
    context 'when patching a text-attribute succeeds', ->
      it 'sets the successfully patched attribute on the model', ->
        @modelPatch._applyPatch(@lastPatch, @model, @firstPatch, @current)
        expect(@setStub).toHaveBeenCalledWith('text', 
                                              'patched_value', 
                                              skipPatch: true)
                                            
      it 'returns true', ->
        expect(
          @modelPatch._applyPatch(@lastPatch, @model, @firstPatch, @current)
        ).toBeTruthy()
      
    context 'when patching a text-attribute fails', ->
      beforeEach ->
        @patchApplyStub.restore()
        @patchApplyStub = sinon.stub(@dmp, 
                                     'patch_apply', 
                                     -> ['patched_value', [false]])
        
      it 'does not set the patched attribute on the model', ->
        @modelPatch._applyPatch(@lastPatch, @model, @firstPatch, @current)
        expect(@setStub).not.toHaveBeenCalledWith('text', 
                                                  'patched_value', 
                                                  skipPatch: true)
        
      it 'returns false', ->
        expect(
          @modelPatch._applyPatch(@lastPatch, @model, @firstPatch, @current)
        ).toBeFalsy()
        
      
      


