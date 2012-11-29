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
    deleteCount  = Util.randomFrom(0, 2)
    changeCount  = Util.randomFrom(4, 8)
    createCount  = Util.randomFrom(0, 2)
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