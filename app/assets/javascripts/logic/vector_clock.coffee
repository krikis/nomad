class @VectorClock
  # Instantiate new clock
  constructor: (clocks) ->
    @[clock] = value for clock, value of clocks
    
  # Helper method
  _defineClocksOf: (otherVector) ->
    @[clock] ||= 0 for clock of otherVector
    
  # Does the clock equal the other clock?
  equals: (otherVector) ->
    @_defineClocksOf(otherVector)
    _.all _.properties(@), (clock) =>
      @[clock] == (otherVector[clock] || 0)
  
  # Does the clock supersede the other clock?
  supersedes: (otherVector) ->
    @_defineClocksOf(otherVector)
    some_greater = _.some _.properties(@), (clock) =>
      @[clock] > (otherVector[clock] || 0)
    all_greater_equal = _.all _.properties(@), (clock) =>
      @[clock] >= (otherVector[clock] || 0)
    some_greater and all_greater_equal
    
  # Does the clock conflict with the other clock?
  conflictsWith: (otherVector) ->
    @_defineClocksOf(otherVector)
    some_greater = _.some _.properties(@), (clock) =>
      @[clock] > (otherVector[clock] || 0)
    some_less = _.some _.properties(@), (clock) =>
      @[clock] < (otherVector[clock] || 0)
    some_greater and some_less
    
    