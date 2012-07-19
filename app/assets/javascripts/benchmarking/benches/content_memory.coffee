Benches = @Benches ||= {}

Benches.setupContent = (next) ->
  class Answer extends Backbone.Model
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

Benches.beforeContent = (next) ->
  @answer = new @Answer Benches.fixedAnswer()
  next.call @

Benches.content = (next) ->
  @answer.set Benches.fixedAnswerV1u1()
  @answer.set Benches.fixedAnswerV1u2()
  @answer.set Benches.fixedAnswerV1u3()
  next.call @