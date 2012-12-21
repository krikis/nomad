Benches = @Benches ||= {}

Benches.setupStructRebase1 = (next) ->
  class Answer extends Backbone.Model
    versioning: 'structured_content_diff'
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

Benches.beforeStructRebase1 = (next) ->
  @answer = new @Answer Benches.fixedAnswer()
  @answer.set Benches.fixedAnswerV1u1()
  @dummy = new @Answer Benches.fixedAnswerV2()
  next.call @

Benches.structRebase1 = (next) ->
  @success = @answer._applyPatchesTo @dummy
  window.struct = JSON.stringify @dummy._sortPropertiesIn @dummy.attributes
  next.call @