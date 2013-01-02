Benches = @Benches ||= {}

# setup data model
Benches.setupMergeAddVersion12 = (next) ->
  class Answer extends Backbone.Model
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

# create data object
Benches.beforeMergeAddVersion12 = (next) ->
  @answerOriginal = Util.randomObject()
  @answer = new @Answer _.deepClone @answerOriginal
  next.call @

# perform update on data object
Benches.mergeAddVersion12 = (next) ->
  [version, deleted] = Util.randomVersion(@answerOriginal, 0.125)
  @answer.set version
  _.each deleted, (property)=>
    @answer.unset property
  next.call @