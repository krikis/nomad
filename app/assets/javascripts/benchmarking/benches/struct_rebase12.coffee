Benches = @Benches ||= {}

Benches.setupStructRebase12 = (next) ->
  # define a model
  class Answer extends Backbone.Model
    versioning: 'structured_content_diff'
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

Benches.beforeStructRebase12= (next) ->  
  # create the original data version
  @answerOriginal = Util.randomObject()
  @answer = new @Answer _.deepClone @answerOriginal
  # perform the winning update
  [dummyVersion, deleted] = Util.randomVersion(@answerOriginal, 0.125)
  @dummy = new @Answer _.deepClone dummyVersion
  # perform the losing update
  [version, deleted] = Util.randomVersion(@answerOriginal, 0.125)
  @answer.set version
  _.each deleted, (property)=>
    @answer.unset property
  next.call @

Benches.structRebase12= (next) ->
  # resolve the conflicts
  @success = @answer._applyPatchesTo @dummy
  next.call @