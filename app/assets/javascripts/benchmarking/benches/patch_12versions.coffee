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
  @answer = new @Answer _.deepClone @answerOriginal
  next.call @

Benches.patch12 = (next) ->  
  deleteCount  = Util.randomFrom(0, 2)
  changeCount  = Util.randomFrom(4, 8)
  createCount  = Util.randomFrom(0, 2)
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