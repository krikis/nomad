Benches = @Benches ||= {}

# setup data model
Benches.setupMergeAddVersion25 = (next) ->
  class Answer extends Backbone.Model
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

# create data object
Benches.beforeMergeAddVersion25 = (next) ->
  @answerOriginal = Util.randomObject()
  @answer = new @Answer _.deepClone @answerOriginal
  next.call @

# perform update on data object
Benches.mergeAddVersion25 = (next) ->
  [version, deleted] = Util.randomVersion(@answerOriginal, change: 0.25)
  @answer.set version
  _.each deleted, (property)=>
    @answer.unset property
  next.call @