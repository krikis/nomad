describe 'ModelPatch', ->
  beforeEach ->
    @modelPatch = new ModelPatch
    
  describe '#updateFor', ->
    beforeEach ->
      @modelPatch._patch  = 'old_patch'
      @changedAttributes  = sinon.stub()
      @previousAttributes = sinon.stub()
      @updatePatchForStub = sinon.stub(@modelPatch, '_updatePatchFor', -> 'new_patch')
      
    it 'calls the _updatePatchFor method', ->
      @modelPatch.updateFor(@changedAttributes,
                            @previousAttributes)
      expect(@updatePatchForStub).
        toHaveBeenCalledWith('old_patch',
                             @changedAttributes,
                             @previousAttributes)
                             
    it 'stores the output in _patch', ->
      @modelPatch.updateFor(@changedAttributes,
                            @previousAttributes)
      expect(@modelPatch._patch).toEqual('new_patch')

  describe '#_updatePatchFor', ->
    beforeEach ->
      @changedAttributes =
        number: 1234.5
        text: 'some_text'
      @previousAttributes =
        number: 1001.1
        text: 'previous_text'

    it 'saves all changed no-text attributes', ->
      patch = @modelPatch._updatePatchFor(null,
                                          @changedAttributes,
                                          @previousAttributes)
      expect(patch.number).
        toEqual(@changedAttributes.number)

    context 'when no patch object exists', ->
      it 'initializes the patch object', ->
        patch = @modelPatch._updatePatchFor(null,
                                            @changedAttributes,
                                            @previousAttributes)
        expect(patch).toBeDefined()

      it 'retains the previous version of all text attributes', ->
        patch = @modelPatch._updatePatchFor(null,
                                            @changedAttributes,
                                            @previousAttributes)
        expect(patch.text).toEqual('previous_text')

    context 'when a patch object exists', ->
      beforeEach ->
        @patch =
          number: 1001.1
          text: 'original_text'

      it 'retains the original version of all text attributes', ->
        patch = @modelPatch._updatePatchFor(@patch,
                                            @changedAttributes,
                                            @previousAttributes)
        expect(patch.text).toEqual('original_text')

    context 'when the changed attributes contain an object', ->
      beforeEach ->
        @changedAttributes =
          object:
            number: 1234.5
            text: 'some_text'
        @updatePatchSpy = sinon.spy(@modelPatch, '_updatePatchFor')

      it 'recursively updates the patch for this object', ->
        patch = @modelPatch._updatePatchFor(@patch,
                                            @changedAttributes,
                                            @previousAttributes)
        expect(@updatePatchSpy).
          toHaveBeenCalledWith(undefined, number: 1234.5, text: 'some_text', undefined)