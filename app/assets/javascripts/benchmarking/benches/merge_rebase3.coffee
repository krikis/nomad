Benches = @Benches ||= {}

Benches.setupMergeRebase3 = (next) ->
  # define a model
  class Answer extends Backbone.Model
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

Benches.beforeMergeRebase3 = (next) ->  
  # instantiate a data object with up to date data
  @dummy = new @Answer Benches.fixedAnswerV2()
  # instantiate a data object with outdated data
  @answer = new @Answer Benches.fixedAnswer()
  # perform a number of conflicting updates
  @answer.set Benches.fixedAnswerV1u1()
  @answer.updateSyncingVersions()
  @answer.set Benches.fixedAnswerV1u2()
  @answer.updateSyncingVersions()
  @answer.set Benches.fixedAnswerV1u3()
  next.call @

Benches.mergeRebase3 = (next) ->
  # resolve the conflicts
  @success = @answer._applyPatchesTo @dummy
  window.merge = JSON.stringify @dummy._sortPropertiesIn @dummy.attributes
  next.call @