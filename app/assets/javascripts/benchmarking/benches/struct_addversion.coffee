Benches = @Benches ||= {}

Benches.setupStructAddVersion = (next) ->
  class Answer extends Backbone.Model
    versioning: 'structured_content_diff'
  @Answer = Answer 

Benches.beforeStructAddVersion = (next) ->
  @answer = new Answer Benches.fixedAnswer

Benches.structAddVersion = (next) ->
  @answer.save Benches.fixedAnswerV1
  console.log @answer.changedAttributes()
