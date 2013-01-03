Benches = @Benches ||= {}

Benches.setupPatch3 = (next) ->
  class Answer extends Backbone.Model
    versioning: 'structured_content_diff'
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

Benches.beforePatch3 = (next) ->
  @answerOriginal = Util.randomObject()
  @answerVersion = _.deepClone @answerOriginal
  @answer = new @Answer _.deepClone @answerOriginal
  next.call @

Benches.patch3 = (next) ->  
  _.each [1..3], =>
    [@answerVersion, deleted] = Util.randomVersion(@answerVersion, 0.25)
    @answer.set _.deepClone @answerVersion
    _.each deleted, (property)=>
      @answer.unset property
  next.call @