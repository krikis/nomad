Benches = @Benches ||= {}

Benches.setupContent6 = (next) ->
  class Answer extends Backbone.Model
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

Benches.beforeContent6 = (next) ->
  @answerOriginal = Util.randomObject()
  @answerVersion = _.deepClone @answerOriginal
  @answer = new @Answer _.deepClone @answerOriginal
  next.call @

Benches.content6 = (next) ->  
  _.each [1..6], =>
    deleteCount  = 0
    changeCount  = Util.randomFrom(4, 8)
    createCount  = 0
    textChange   = 15
    stringChange = 5
    [@answerVersion, deleted] = Util.randomVersion(@answerVersion,
                                                   deleteCount,   
                                                   changeCount,   
                                                   createCount,   
                                                   textChange,   
                                                   stringChange)
    @answer.set _.deepClone @answerVersion
    _.each deleted, (property)=>
      @answer.unset property
  next.call @