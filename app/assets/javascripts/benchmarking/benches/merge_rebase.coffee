Benches = @Benches ||= {}

Benches.setupMergeRebase = (next) ->
  class Answer extends Backbone.Model
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

Benches.beforeMergeRebase = (next) ->
  @answer = new @Answer Benches.fixedAnswer
  @answer.set Benches.fixedAnswerV1
  @dummy = new @Answer Benches.fixedAnswerV2
  next.call @

Benches.mergeRebase = (next) ->
  @answer._applyPatchesTo @dummy
  console.log JSON.stringify @dummy.attributes
  next.call @