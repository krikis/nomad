Benches = @Benches ||= {}

Benches.setupStructAddVersion3 = (next) ->
  class Answer extends Backbone.Model
    versioning: 'structured_content_diff'
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

Benches.beforeStructAddVersion3 = (next) ->
  @answer = new @Answer Benches.fixedAnswer()
  next.call @

Benches.structAddVersion3 = (next) ->
  @answer.set Benches.fixedAnswerV1u1()
  @answer.updateSyncingVersions()
  @answer.set Benches.fixedAnswerV1u2()
  @answer.updateSyncingVersions()
  @answer.set Benches.fixedAnswerV1u3()
  next.call @
