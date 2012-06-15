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
      