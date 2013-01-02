Benches = @Benches ||= {}

Benches.setupMergeRebase25 = (next) ->
  # define a model
  class Answer extends Backbone.Model
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

Benches.beforeMergeRebase25 = (next) ->  
  # create the original data version
  @answerOriginal = Util.randomObject()
  @answer = new @Answer _.deepClone @answerOriginal
  # perform the winning update
  [dummyVersion, deleted] = Util.randomVersion(@answerOriginal, 0.25)
  @dummy = new @Answer _.deepClone dummyVersion
  # perform the losing update
  [version, deleted] = Util.randomVersion(@answerOriginal, 0.25)
  @answer.set version
  _.each deleted, (property)=>
    @answer.unset property
  next.call @

Benches.mergeRebase25 = (next) ->
  # resolve the conflicts
  try
    @success = @answer._applyPatchesTo @dummy
  catch error
    @suite?.log error.message
    @suite?.log error.stack
    @success = false
  finally
    next.call @