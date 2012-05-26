describe 'Strings', ->
  
  describe '#underscore', ->
    it 'converts camelcase to underscored format', ->
      expect('MyCollection'.underscore()).toEqual('my_collection')