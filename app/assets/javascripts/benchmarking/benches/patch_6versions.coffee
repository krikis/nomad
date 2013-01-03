Benches = @Benches ||= {}

Benches.setupPatch6 = (next) ->
  class Answer extends Backbone.Model
    versioning: 'structured_content_diff'
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

Benches.beforePatch6 = (next) ->
  @answerOriginal = Util.randomObject()
  @answerVersion = _.deepClone @answerOriginal
  @answer = new @Answer _.deepClone @answerOriginal
  next.call @

Benches.patch6 = (next) ->  
  _.each [1..6], =>
    [@answerVersion, deleted] = Util.randomVersion(@answerVersion, 0.5)
    @answer.set _.deepClone @answerVersion
    _.each deleted, (property)=>
      @answer.unset property
  next.call @