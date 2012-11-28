Benches = @Benches ||= {}

Benches.setupStructRebase3 = (next) ->
  class Answer extends Backbone.Model
    versioning: 'structured_content_diff'
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

Benches.beforeStructRebase3 = (next) ->
  @answer = new @Answer Benches.fixedAnswer()
  @answer.set Benches.fixedAnswerV1u1()
  @answer.set Benches.fixedAnswerV1u2()
  @answer.set Benches.fixedAnswerV1u3()
  @dummy = new @Answer Benches.fixedAnswerV2()
  next.call @

Benches.structRebase3 = (next) ->
  @success = @answer._applyPatchesTo @dummy
  window.struct = JSON.stringify @dummy._sortPropertiesIn @dummy.attributes
  next.call @