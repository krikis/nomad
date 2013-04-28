Benches = @Benches ||= {}

Benches.setupMemory = (next, options = {}) ->
  class Answer extends Backbone.Model
    versioning: options.versioning
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

Benches.beforeMemory = (next, options = {}) ->
  @answerOriginal = Util.randomObject()
  @answerVersion = _.deepClone @answerOriginal
  @answer = new @Answer _.deepClone @answerOriginal
  next.call @

Benches.memory = (next, options = {}) ->
  changeRate = 0.25
  _.each [1..options.nrOfUpdates], =>
    [@answerVersion, deleted] = Util.randomVersion(@answerVersion, change: changeRate)
    @answer.set _.deepClone @answerVersion
    _.each deleted, (property)=>
      @answer.unset property
  next.call @