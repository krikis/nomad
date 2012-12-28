Benches = @Benches ||= {}

# setup data model
Benches.setupMergeAddVersion3 = (next) ->
  class Answer extends Backbone.Model
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

# create data object
Benches.beforeMergeAddVersion3 = (next) ->
  @answer = new @Answer Benches.fixedAnswer()
  next.call @

# perform three updates on data object 
Benches.mergeAddVersion3 = (next) ->
  @answer.set Benches.fixedAnswerV1u1()
  @answer.updateSyncingVersions()
  @answer.set Benches.fixedAnswerV1u2()
  @answer.updateSyncingVersions()
  @answer.set Benches.fixedAnswerV1u3()
  next.call @