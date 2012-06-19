describe 'array_extensions', ->
  
  describe '#delete', ->
    beforeEach ->
      @array = [1, 2, 3, 1]
      @value = 1
    
    it 'deletes every occurrence of value from array', ->
      @array.delete @value
      expect(@array).toEqual([2, 3])
  
  describe '#merge', ->
    beforeEach ->
      @array = [1]
      @other = [2]
      
    it 'merges other into array', ->
      @array.merge(@other)
      expect(@array).toEqual([1, 2])