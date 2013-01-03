Benches = @Benches ||= {}

Benches.setupContent9 = (next) ->
  class Answer extends Backbone.Model
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

Benches.beforeContent9 = (next) ->  
  @answerOriginal = Util.randomObject()
  @answerVersion = _.deepClone @answerOriginal
  @answer = new @Answer _.deepClone @answerOriginal
  next.call @

Benches.content9 = (next) ->    
  _.each [1..9], =>
    [@answerVersion, deleted] = Util.randomVersion(@answerVersion, 0.25)
    @answer.set _.deepClone @answerVersion
    _.each deleted, (property)=>
      @answer.unset property
  next.call @