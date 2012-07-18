Benches = @Benches ||= {}

Benches.setupStructRebase = (next) ->
  class Answer extends Backbone.Model
    versioning: 'structured_content_diff'
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

Benches.beforeStructRebase = (next) ->
  @answer = new @Answer Benches.fixedAnswer()
  @answer.set Benches.fixedAnswerV1u1()
  @answer.set Benches.fixedAnswerV1u2()
  @answer.set Benches.fixedAnswerV1u3()
  @dummy = new @Answer Benches.fixedAnswerV2()
  next.call @

Benches.structRebase = (next) ->
  @answer._applyPatchesTo @dummy
  window.struct = JSON.stringify @dummy._sortPropertiesIn @dummy.attributes
  next.call @