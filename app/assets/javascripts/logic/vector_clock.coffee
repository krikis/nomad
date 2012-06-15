class @VectorClock
  constructor: (clocks) ->
    @[clock] = value for clock, value of clocks
    
  _defineClocksOf: (otherVector) ->
    @[clock] ||= 0 for clock of otherVector
    
  equals: (otherVector) ->
    @_defineClocksOf(otherVector)
    _.all _.properties(@), (clock) =>
      @[clock] == (otherVector[clock] || 0)
  
  supersedes: (otherVector) ->
    @_defineClocksOf(otherVector)
    some_greater = _.some _.properties(@), (clock) =>
      @[clock] > (otherVector[clock] || 0)
    all_greater_equal = _.all _.properties(@), (clock) =>
      @[clock] >= (otherVector[clock] || 0)
    some_greater and all_greater_equal
    
  conflictsWith: (otherVector) ->
    @_defineClocksOf(otherVector)
    some_greater = _.some _.properties(@), (clock) =>
      @[clock] > (otherVector[clock] || 0)
    some_less = _.some _.properties(@), (clock) =>
      @[clock] < (otherVector[clock] || 0)
    some_greater and some_less
    
    