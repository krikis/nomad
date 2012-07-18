describe 'underscore_extensions', ->
  describe '_.properties', ->
    beforeEach -> 
      class SomeObject
        constructor: (some_value) ->
          @some_property = some_value
        some_function: ->
          @some_property
      @some_object = new SomeObject('some_value')
    
    it 'returns all own properties of an object', ->
      expect(_.properties(@some_object)).toContain('some_property')
      
    it 'does not include any own functions defined on the object', ->
      expect(_.properties(@some_object)).not.toContain('some_function')
      
  describe '_.deepClone', ->
    beforeEach ->
      @deepExtendStub = sinon.stub(_, 'deepExtend')
      
    afterEach ->
      @deepExtendStub.restore()
        
    it 'returns the argument when it is not an object', ->
      clone = _.deepClone('someText')
      expect(clone).toEqual('someText')
      
    it 'slices the argument when it is an array', ->
      array = []
      sliceStub = sinon.stub(array, 'slice')
      clone = _.deepClone(array)
      expect(sliceStub).toHaveBeenCalled()
      
    it 'deep-extends the argument when it is a regular object', ->
      object = {ob: 'ject'}
      clone = _.deepClone(object)
      expect(@deepExtendStub).toHaveBeenCalledWith({}, object)
      
  describe '_.deepExtend', ->
    beforeEach ->
      @deepCloneStub = sinon.stub(_, 'deepClone', -> 'deep_clone')
      
    afterEach ->
      @deepCloneStub.restore()
      
    it 'deep-clones each property of the source', ->
      object = 
        property: 'value'
      extended = _.deepExtend {}, object
      expect(@deepCloneStub).toHaveBeenCalledWith('value')
      
    it 'sets the cloned properties on the object', ->
      object = 
        property: 'value'
      extended = _.deepExtend {}, object
      expect(extended.property).toEqual 'deep_clone'
      
      