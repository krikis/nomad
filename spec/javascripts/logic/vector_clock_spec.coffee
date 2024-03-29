describe 'VectorClock', ->
  beforeEach -> 
    @vector = new VectorClock
      some_clock: 1
      other_clock: 2
      
  describe '#new', ->
    it 'initializes the vector with the clocks provided', ->
      expect(@vector.some_clock).toEqual(1)
      expect(@vector.other_clock).toEqual(2)
      
  describe '#_defineClocksOf', ->    
    beforeEach ->
      @otherVector = new VectorClock
        some_clock: 1
        other_clock: 2
        undefined_clock: 1
    
    it 'initializes clocks to 0 for all clocks
        in otherVector that are undefined in vector', ->
      @vector._defineClocksOf(@otherVector)
      expect(@vector.undefined_clock).toEqual(0)
      
  describe '#equals', ->
    context 'when all clocks in vector and otherVector are equal', ->
      beforeEach ->
        @otherVector = new VectorClock
          some_clock: 1
          other_clock: 2
      
      it 'returns true', ->
        expect(@vector.equals(@otherVector)).toBeTruthy()
        
    context 'when at least one clock is different', ->
      beforeEach ->
        @otherVector = new VectorClock
          some_clock: 1
          other_clock: 3
      
      it 'returns false', ->
        expect(@vector.equals(@otherVector)).toBeFalsy()
        
    context 'when at least one clock is undefined in a vector', ->
      beforeEach ->
        @otherVector = new VectorClock
          some_clock: 1
          other_clock: 2
          undefined_clock: 1
      
      it 'returns false', ->
        expect(@vector.equals(@otherVector)).toBeFalsy()
        
  
  describe '#supersedes', ->    
    context 'when at least one clock in vector supersedes 
             the corresponding clock in otherVector', ->
      beforeEach ->
        @otherVector = new VectorClock
          some_clock: 1
          other_clock: 1
              
      it 'returns true', ->
        expect(@vector.supersedes(@otherVector)).toBeTruthy()
        
    context 'when at least one clock in vector is undefined
             in otherVector', ->
      beforeEach ->
        @otherVector = new VectorClock
          some_clock: 1
      
      it 'returns true', ->
        expect(@vector.supersedes(@otherVector)).toBeTruthy()
        
    context 'when no clock in vector supersedes
             the corresponding clock in otherVector', ->
      beforeEach ->
        @otherVector = new VectorClock
          some_clock: 2
          other_clock: 2
          
      it 'returns false', ->
        expect(@vector.supersedes(@otherVector)).toBeFalsy()
        
    context 'when at least one clock in otherVector is undefined
             in vector', ->
      beforeEach ->
        @otherVector = new VectorClock
          some_clock: 1
          undefined_clock: 1
      
      it 'returns false', ->
        expect(@vector.supersedes(@otherVector)).toBeFalsy()
        
    context 'when the vectors conflict', ->    
      beforeEach ->
        @otherVector = new VectorClock
          some_clock: 2
          other_clock: 1
          
      it 'returns false', ->
        expect(@vector.supersedes(@otherVector)).toBeFalsy()
        
  describe '#conflictsWith', ->
    context 'when at least one clock in vector supersedes 
             a clock in otherVector and viceVersa', ->
      beforeEach ->
        @otherVector = new VectorClock
          some_clock: 2
          other_clock: 1
      
      it 'returns true', ->
        expect(@vector.conflictsWith(@otherVector)).toBeTruthy()
      
    context 'when at least one clock in vector supersedes 
             a clock in otherVector and viceVersa', ->
      beforeEach ->
        @otherVector = new VectorClock
          some_clock: 1
          undefined_clock: 1
    
      it 'returns true', ->
        expect(@vector.conflictsWith(@otherVector)).toBeTruthy()
        
    context 'when the vectors equal', ->    
      beforeEach ->
        @otherVector = new VectorClock
          some_clock: 1
          other_clock: 2

      it 'returns false', ->
        expect(@vector.conflictsWith(@otherVector)).toBeFalsy()
        
    context 'when vector supersedes otherVector', ->    
      beforeEach ->
        @otherVector = new VectorClock
          some_clock: 1
          other_clock: 1

      it 'returns false', ->
        expect(@vector.conflictsWith(@otherVector)).toBeFalsy()
        
    context 'when otherVector supersedes vector', ->    
      beforeEach ->
        @otherVector = new VectorClock
          some_clock: 2
          other_clock: 2

      it 'returns false', ->
        expect(@vector.conflictsWith(@otherVector)).toBeFalsy()
      
      
      
      
      
      
        
  
        