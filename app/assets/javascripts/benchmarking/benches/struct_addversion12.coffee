Benches = @Benches ||= {}

# setup data model
Benches.setupStructAddVersion12 = (next) ->
  class Answer extends Backbone.Model
    versioning: 'structured_content_diff'
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

# create data object
Benches.beforeStructAddVersion12 = (next) ->
  @answerOriginal = Util.randomObject()
  @answer = new @Answer _.deepClone @answerOriginal
  next.call @

# perform update on data object
Benches.structAddVersion12 = (next) ->
  [version, deleted] = Util.randomVersion(@answerOriginal, change: 0.125)
  @answer.set version
  _.each deleted, (property)=>
    @answer.unset property
  next.call @