class @Suite
  constructor: ->
    @benches = []
    
  bench: (options) ->
    bench = new Bench options
    @benches.push bench
    
  MAX_NR_OF_RUNS: 20
  MIN_STABLE_RUNS: 3
    
  run: (button) ->
    @button = button
    $(@button).attr('disabled': true) if @button?
    @runs = 1
    @stableRuns = 0
    @benchIndex = 0
    @runBench()
    
  runBench: ->
    if bench = @benches[@benchIndex]
      bench.run
        next: @nextBench
        context: @
    
  nextBench: ->
    bench = @benches[@benchIndex]
    # let iteration converge when oscillations become smaller than 1%
    if Math.abs(bench.previous - bench.mean) > bench.mean / 100
      @rerunSuite = true
    @benchIndex++
    if @benchIndex < @benches.length
      @runBench()
    else
      @runSuite()
      
  runSuite: ->
    @stableRuns++ unless @rerunSuite
    @rerunSuite = true if @stableRuns < @MIN_STABLE_RUNS
    if @rerunSuite and @runs < @MAX_NR_OF_RUNS
      @rerunSuite = false
      @runs++
      @benchIndex = 0
      @runBench()
    else
      @finish()
    
  finish: ->
    console.log "converged after #{@runs} iterations"  
    $(@button).attr('disabled': false) if @button?  