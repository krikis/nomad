Benches = @Benches ||= {}

Benches.setupMergeAddVersion = (next) ->
  class Answer extends Backbone.Model
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

Benches.beforeMergeAddVersion = (next) ->
  @answer = new @Answer Benches.fixedAnswer()
  next.call @

Benches.mergeAddVersion = (next) ->
  @answer.set Benches.fixedAnswerV1()
  next.call @