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
  @answer = new @Answer _.deepClone @answerOriginal
  next.call @

Benches.patch6 = (next) ->
  deleteCount  = Util.randomFrom(0, 2)
  changeCount  = Util.randomFrom(1, 4)
  createCount  = Util.randomFrom(1, 2)
  textChange   = 8
  stringChange = 3
  _.each [1..6], =>
    @answerOriginal = Util.randomVersion(@answerOriginal,
                                         deleteCount,   
                                         changeCount,   
                                         createCount,   
                                         textChange,   
                                         stringChange)
    @answer.set _.deepClone @answerOriginal
  next.call @