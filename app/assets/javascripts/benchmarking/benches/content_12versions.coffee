Benches = @Benches ||= {}

Benches.setupContent12 = (next) ->
  class Answer extends Backbone.Model
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

Benches.beforeContent12 = (next) ->  
  @answerOriginal = Util.randomObject()
  @answerVersion = _.deepClone @answerOriginal
  @answer = new @Answer _.deepClone @answerOriginal
  next.call @

Benches.content12 = (next) ->    
  _.each [1..12], =>
    [@answerVersion, deleted] = Util.randomVersion(@answerVersion, change: 0.25)
    @answer.set _.deepClone @answerVersion
    _.each deleted, (property)=>
      @answer.unset property
  next.call @