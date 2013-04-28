Benches = @Benches ||= {}

# recording local upates
# setup data model
Benches.setupRecordOverhead = (next, options = {}) ->
  class Answer extends Backbone.Model
    versioning: options.versioning
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

# create data object
Benches.beforeRecordOverhead = (next, options = {}) ->
  @answerOriginal = Util.randomObject(typeOdds: options.typeOdds)
  @answer = new @Answer _.deepClone @answerOriginal
  next.call @

# perform update on data object
Benches.recordOverhead = (next, options = {}) ->
  [version, deleted] = Util.randomVersion(@answerOriginal,
                                          change: options.changeRate,
                                          changeOdds: options.changeOdds)
  @answer.set version
  _.each deleted, (property)=>
    @answer.unset property
  next.call @

#reconciling conflicting updates

Benches.setupReconcileOverhead = (next, options = {}) ->
  # define a model
  class Answer extends Backbone.Model
    versioning: options.versioning
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

Benches.beforeReconcileOverhead = (next, options = {}) ->
  # create the original data version
  @answerOriginal = Util.randomObject(typeOdds: options.typeOdds)
  @answer = new @Answer _.deepClone @answerOriginal
  # perform the winning update
  [dummyVersion, deleted] = Util.randomVersion(@answerOriginal,
                                               change: options.changeRate,
                                               changeOdds: options.changeOdds)
  @dummy = new @Answer _.deepClone dummyVersion
  # perform the losing update
  [version, deleted] = Util.randomVersion(@answerOriginal,
                                          change: options.changeRate,
                                          changeOdds: options.changeOdds)
  @answer.set version
  _.each deleted, (property)=>
    @answer.unset property
  next.call @

Benches.reconcileOverhead = (next, options = {}) ->
  # resolve the conflicts
  try
    @success = @answer._applyPatchesTo @dummy
  catch error
    if error.name == 'SyntaxError'
      @suite?.log 'JSON format broken!'
    else
      @suite?.log error.message
      @suite?.log error.stack
    @success = false
  finally
    next.call @