Benches = @Benches ||= {}

Benches.setupPatch3 = (next) ->
  class Answer extends Backbone.Model
    versioning: 'structured_content_diff'
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

Benches.beforePatch3 = (next) ->
  @answer = new @Answer Benches.fixedAnswer()
  next.call @

Benches.patch3 = (next) ->
  @answer.set Benches.fixedAnswerV1u1()
  @answer.set Benches.fixedAnswerV1u2()
  @answer.set Benches.fixedAnswerV1u3()
  next.call @