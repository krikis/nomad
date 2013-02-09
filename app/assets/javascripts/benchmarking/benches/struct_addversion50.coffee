Benches = @Benches ||= {}

# setup data model
Benches.setupStructAddVersion50 = (next) ->
  class Answer extends Backbone.Model
    versioning: 'structured_content_diff'
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

# create data object
Benches.beforeStructAddVersion50 = (next) ->
  @answerOriginal = Util.randomObject()
  @answer = new @Answer _.deepClone @answerOriginal
  next.call @

# perform update on data object
Benches.structAddVersion50 = (next) ->
  [version, deleted] = Util.randomVersion(@answerOriginal, change: 0.5)
  @answer.set version
  _.each deleted, (property)=>
    @answer.unset property
  next.call @