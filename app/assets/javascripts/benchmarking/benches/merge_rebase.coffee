Benches = @Benches ||= {}

Benches.setupMergeRebase = (next) ->
  class Answer extends Backbone.Model
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

Benches.beforeMergeRebase = (next) ->
  @answer = new @Answer Benches.fixedAnswer()
  @answer.set Benches.fixedAnswerV1u1()
  console.log JSON.stringify @answer._versioning.patches[0]._patch
  @answer.set Benches.fixedAnswerV1u2()
  console.log JSON.stringify @answer._versioning.patches[0]._patch
  @answer.set Benches.fixedAnswerV1u3()
  console.log JSON.stringify @answer._versioning.patches[0]._patch
  @dummy = new @Answer Benches.fixedAnswerV2()
  next.call @

Benches.mergeRebase = (next) ->
  @answer._applyPatchesTo @dummy
  window.merge = JSON.stringify @dummy._sortPropertiesIn @dummy.attributes
  next.call @