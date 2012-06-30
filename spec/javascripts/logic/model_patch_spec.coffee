describe 'ModelPatch', ->
    
  describe '.new', ->
    beforeEach ->
      @changedAttributes  = sinon.stub()
      @previousAttributes = sinon.stub()
      @createPatchForStub = sinon.stub(ModelPatch::, 
                                       '_createPatchFor', 
                                       -> 'new_patch')
      
    afterEach ->
      @createPatchForStub.restore()
      
    it 'calls the _createPatchFor method', ->
      @modelPatch = new ModelPatch(@changedAttributes,
                                   @previousAttributes)
      expect(@createPatchForStub).
        toHaveBeenCalledWith(@changedAttributes,
                             @previousAttributes)
                             
    it 'stores the output in _patch', ->
      @modelPatch = new ModelPatch(@changedAttributes,
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
      @modelPatch = new ModelPatch(@changedAttributes,
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
          
          
          
          