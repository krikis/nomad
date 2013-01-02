Benches = @Benches ||= {}

# setup data model
Benches.setupMergeAddVersion37 = (next) ->
  class Answer extends Backbone.Model
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

# create data object
Benches.beforeMergeAddVersion37 = (next) ->
  @answerOriginal = Util.randomObject()
  @answer = new @Answer _.deepClone @answerOriginal
  next.call @

# perform update on data object
Benches.mergeAddVersion37 = (next) ->
  [version, deleted] = Util.randomVersion(@answerOriginal, 0.375)
  @answer.set version
  _.each deleted, (property)=>
    @answer.unset property
  next.call @