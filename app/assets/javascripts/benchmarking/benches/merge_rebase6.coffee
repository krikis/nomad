Benches = @Benches ||= {}

Benches.setupMergeRebase6 = (next) ->
  class Answer extends Backbone.Model
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

Benches.beforeMergeRebase6 = (next) ->
  @answer = new @Answer Benches.fixedAnswer()
  @answer.set Benches.fixedAnswerV1u1()
  @answer.set Benches.fixedAnswerV1u2()
  @answer.set Benches.fixedAnswerV1u3()
  @answer.set Benches.fixedAnswerV1u4()
  @answer.set Benches.fixedAnswerV1u5()
  @answer.set Benches.fixedAnswerV1u6()
  @dummy = new @Answer Benches.fixedAnswerV2()
  next.call @

Benches.mergeRebase6 = (next) ->
  @success = @answer._applyPatchesTo @dummy
  window.merge = JSON.stringify @dummy._sortPropertiesIn @dummy.attributes
  next.call @