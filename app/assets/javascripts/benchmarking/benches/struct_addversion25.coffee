Benches = @Benches ||= {}

# setup data model
Benches.setupStructAddVersion25 = (next) ->
  class Answer extends Backbone.Model
    versioning: 'structured_content_diff'
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

# create data object
Benches.beforeStructAddVersion25 = (next) ->
  @answerOriginal = Util.randomObject()
  @answer = new @Answer _.deepClone @answerOriginal
  next.call @

# perform update on data object
Benches.structAddVersion25 = (next) ->
  [version, deleted] = Util.randomVersion(@answerOriginal, change: 0.25)
  @answer.set version
  _.each deleted, (property)=>
    @answer.unset property
  next.call @