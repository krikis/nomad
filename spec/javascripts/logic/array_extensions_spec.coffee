describe 'array_extensions', ->
  
  describe '#merge', ->
    beforeEach ->
      @array = [1]
      @other = [2]
      
    it 'merges other into array', ->
      @array.merge(@other)
      expect(@array).toEqual([1, 2])