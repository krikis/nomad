Benches = @Benches ||= {}

Benches.setupStructAddVersion = (next) ->
  class Answer extends Backbone.Model
    versioning: 'structured_content_diff'
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

Benches.beforeStructAddVersion = (next) ->
  @answer = new @Answer Benches.fixedAnswer
  next.call @

Benches.structAddVersion = (next) ->
  @answer.set Benches.fixedAnswerV1
  console.log @answer.changedAttributes()
  next.call @
