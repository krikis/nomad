Benches = @Benches ||= {}

Benches.setupPatch12 = (next) ->
  class Answer extends Backbone.Model
    versioning: 'structured_content_diff'
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

Benches.beforePatch12 = (next) ->
  @answerOriginal = Util.randomObject()
  @answerVersion = _.deepClone @answerOriginal
  @answer = new @Answer _.deepClone @answerOriginal
  next.call @

Benches.patch12 = (next) ->  
  _.each [1..12], =>
    [@answerVersion, deleted] = Util.randomVersion(@answerVersion)
    @answer.set _.deepClone @answerVersion
    _.each deleted, (property)=>
      @answer.unset property
  next.call @