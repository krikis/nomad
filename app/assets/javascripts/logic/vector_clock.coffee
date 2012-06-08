class @VectorClock
  constructor: (clocks) ->
    @[id] = clock for id, clock of clocks
    
  defineClocksOf: (otherVector) ->
    @[clock] ||= 0 for clock of otherVector
    
  equals: (otherVector) ->
    @defineClocksOf(otherVector)
    _.all _.keys(@), (clock) =>
      @[clock] == (otherVector[clock] || 0)
  
  supersedes: (otherVector) ->
    @defineClocksOf(otherVector)
    some_greater = _.some _.keys(@), (clock) =>
      @[clock] > (otherVector[clock] || 0)
    all_greater_equal = _.all _.keys(@), (clock) =>
      @[clock] >= (otherVector[clock] || 0)
    some_greater and all_greater_equal
    
  conflictsWith: (otherVector) ->
    @defineClocksOf(otherVector)
    some_greater = _.some _.keys(@), (clock) =>
      @[clock] > (otherVector[clock] || 0)
    some_less = _.some _.keys(@), (clock) =>
      @[clock] < (otherVector[clock] || 0)
    some_greater and some_less
    
    