Benches = @Benches ||= {}

Benches.setupContent12 = (next) ->
  class Answer extends Backbone.Model
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

Benches.beforeContent12 = (next) ->  
  @answerOriginal = Util.randomObject()
  @answer = new @Answer _.deepClone @answerOriginal
  next.call @

Benches.content12 = (next) ->    
  # specify the amount of random change
  deleteCount  = Util.randomFrom(1, 3)
  changeCount  = Util.randomFrom(4, 8)
  createCount  = Util.randomFrom(1, 3)
  textChange   = 15
  stringChange = 5
  _.each [1..12], =>
    @answerOriginal = Util.randomVersion(@answerOriginal,
                                         deleteCount,   
                                         changeCount,   
                                         createCount,   
                                         textChange,   
                                         stringChange)
    @answer.set _.deepClone @answerOriginal
  next.call @