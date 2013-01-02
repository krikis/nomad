Benches = @Benches ||= {}

Benches.setupMergeRebase1 = (next) ->
  # define a model
  class Answer extends Backbone.Model
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

Benches.beforeMergeRebase1 = (next) ->  
  # instantiate a data object with up to date data
  @dummy = new @Answer Benches.fixedAnswerV2()
  # instantiate a data object with outdated data
  @answer = new @Answer Benches.fixedAnswer()
  # perform a conflicting update
  @answer.set Benches.fixedAnswerV1u1()
  next.call @

Benches.mergeRebase1 = (next) ->
  # resolve the conflicts
  @success = @answer._applyPatchesTo @dummy
  next.call @