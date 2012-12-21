Benches = @Benches ||= {}

Benches.setupStructAddVersion1 = (next) ->
  class Answer extends Backbone.Model
    versioning: 'structured_content_diff'
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

Benches.beforeStructAddVersion1 = (next) ->
  @answer = new @Answer Benches.fixedAnswer()
  next.call @

Benches.structAddVersion1 = (next) ->
  @answer.set Benches.fixedAnswerV1u1()
  next.call @
