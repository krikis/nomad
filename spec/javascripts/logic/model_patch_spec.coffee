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
      @attributesToPatch = sinon.stub()
      @model =
        attributes: @attributesToPatch
      @firstPatch = sinon.stub()
      @first =
        _patch: @firstPatch
      @current = sinon.stub()

    afterEach ->
      @createPatchForStub.restore()

    it 'calls _applyPatch', ->
      @modelPatch.applyTo(@model, @first, @current)
      expect(@applyPatchStub).toHaveBeenCalledWith(@patch,
                                                   @attributesToPatch,
                                                   @firstPatch,
                                                   @current)

  describe '#_applyPatch', ->
    beforeEach ->
      @createPatchForStub = sinon.stub(ModelPatch::,
                                       '_createPatchFor',
                                       -> 'new_patch')
      @modelPatch = new ModelPatch
      @patchAttributeStub = sinon.stub(@modelPatch, '_patchAttribute')
      @originalValue = sinon.stub()
      @firstPatch = 
        attribute: @originalValue
      @value = sinon.stub()
      @lastPatch =
        attribute: @value
      @currentValue = sinon.stub()
      @current = 
        attribute: @currentValue
      @attributesToPatch = sinon.stub()

    afterEach ->
      @createPatchForStub.restore()
      
    it 'calls the _patchAttribute method for each attribute', ->
      @modelPatch._applyPatch(@lastPatch, @attributesToPatch, 
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
        @patchAttributeStub = sinon.stub(@modelPatch, '_patchAttribute', ->
          @out ||= [true, true]
          @out.pop()
        )
        
      it 'returns true', ->
        expect(
          @modelPatch._applyPatch(@lastPatch, @attributesToPatch, 
                                  @firstPatch, @current)
        ).toBeTruthy()
    
    context 'when at least one call for an attribute returns false', ->
      beforeEach ->
        @firstPatch.secondAttribute = sinon.stub()
        @lastPatch .secondAttribute = sinon.stub()
        @current   .secondAttribute = sinon.stub()
        @patchAttributeStub.restore()
        @patchAttributeStub = sinon.stub(@modelPatch, '_patchAttribute', ->
          @out ||= [false, true]
          @out.pop()
        )
    
      it 'returns false', ->
        expect(
          @modelPatch._applyPatch(@lastPatch, @attributesToPatch, 
                                  @firstPatch, @current)
        ).toBeFalsy()

  describe '_patchAttribute', ->
    beforeEach ->
      @createPatchForStub = sinon.stub(ModelPatch::,
                                       '_createPatchFor',
                                       -> 'new_patch')
      @modelPatch = new ModelPatch

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
        @modelPatch._patchAttribute(@attribute, @value, @attributesToPatch, 
                                    @originalValue, @currentValue)
        expect(@attributesToPatch[@attribute]).toEqual(@currentValue)
                                              
      it 'returns true', ->
        expect(
          @modelPatch._patchAttribute(@attribute, @value, @attributesToPatch, 
                                      @originalValue, @currentValue)
        ).toBeTruthy()
        
    context 'when it concerns an object', ->
      beforeEach ->
        @attribute = 'attribute'
        @value = sinon.stub()
        @objectToPatch = sinon.stub()
        @attributesToPatch =
          attribute: @objectToPatch
        @originalValue = sinon.stub()
        @currentValue = 
          attribute: 'value'
        @applyPatchStub = sinon.stub(@modelPatch, '_applyPatch')
          
      it 'recursively calls the _applyPatch method', ->
        @modelPatch._patchAttribute(@attribute, @value, @attributesToPatch, 
                                    @originalValue, @currentValue)
        expect(@applyPatchStub).
          toHaveBeenCalledWith(@value, @objectToPatch, 
                               @originalValue, @currentValue)
    
    context 'when it concerns a text attribute', ->
      beforeEach ->
        @attribute = 'text'
        @value = sinon.stub()
        @attributesToPatch =
          text: 'model_text'
        @originalValue = 'original_text'
        @currentValue = 'current_text'
        @dmp = new diff_match_patch
        @modelPatch.dmp = @dmp
        @dmpStub        = sinon.stub(window, 'diff_match_patch', => @dmp)
        @diffStub       = sinon.stub(@dmp, 'diff_main', -> 'some_diff')
        @patchStub      = sinon.stub(@dmp, 'patch_make', -> 'some_patch')
        @patchApplyStub = sinon.stub(@dmp, 'patch_apply', 
                                     -> ['patched_value', [true]])

      afterEach ->
        @dmpStub.restore()

      it 'generates a diff for the attribute', ->  
        @modelPatch._patchAttribute(@attribute, @value, @attributesToPatch, 
                                    @originalValue, @currentValue)
        expect(@diffStub).toHaveBeenCalledWith(@originalValue, @currentValue)
      
      it 'generates a patch for the attribute', ->
        @modelPatch._patchAttribute(@attribute, @value, @attributesToPatch, 
                                    @originalValue, @currentValue)
        expect(@patchStub).toHaveBeenCalledWith(@originalValue, 'some_diff')
      
      it 'applies a patch on the model attribute', ->
        @modelPatch._patchAttribute(@attribute, @value, @attributesToPatch, 
                                    @originalValue, @currentValue)
        expect(@patchApplyStub).toHaveBeenCalledWith('some_patch', 
                                                     'model_text')
    
      context 'and patching a text-attribute succeeds', ->
        it 'sets the successfully patched attribute on the model', ->
          @modelPatch._patchAttribute(@attribute, @value, @attributesToPatch, 
                                      @originalValue, @currentValue)
          expect(@attributesToPatch.text).toEqual('patched_value')
                                            
        it 'returns true', ->
          expect(
            @modelPatch._patchAttribute(@attribute, @value, @attributesToPatch, 
                                        @originalValue, @currentValue)
          ).toBeTruthy()
      
      context 'and patching a text-attribute fails', ->
        beforeEach ->
          @patchApplyStub.restore()
          @patchApplyStub = sinon.stub(@dmp, 
                                       'patch_apply', 
                                       -> ['patched_value', [false]])
        
        it 'does not set the patched attribute on the model', ->
          @modelPatch._patchAttribute(@attribute, @value, @attributesToPatch, 
                                      @originalValue, @currentValue)
          expect(@attributesToPatch.text).toEqual('model_text')
        
        it 'returns false', ->
          expect(
            @modelPatch._patchAttribute(@attribute, @value, @attributesToPatch, 
                                        @originalValue, @currentValue)
          ).toBeFalsy()
          
      context 'and the original value is not text', ->
        beforeEach ->
          @originalValue = sinon.stub()
          
        it 'sets the current value on the model', ->
          @modelPatch._patchAttribute(@attribute, @value, @attributesToPatch, 
                                      @originalValue, @currentValue)
          expect(@attributesToPatch.text).toEqual(@currentValue)
        
        it 'returns true', ->
          expect(
            @modelPatch._patchAttribute(@attribute, @value, @attributesToPatch, 
                                        @originalValue, @currentValue)
          ).toBeTruthy()
      
        
      
      


