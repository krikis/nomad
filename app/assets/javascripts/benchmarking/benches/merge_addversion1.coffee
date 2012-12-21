Benches = @Benches ||= {}

# setup data model
Benches.setupMergeAddVersion1 = (next) ->
  class Answer extends Backbone.Model
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

# create data object
Benches.beforeMergeAddVersion1 = (next) ->
  @answer = new @Answer Benches.fixedAnswer()
  next.call @

# perform three updates on data object 
Benches.mergeAddVersion1 = (next) ->
  @answer.set Benches.fixedAnswerV1u1()
  next.call @