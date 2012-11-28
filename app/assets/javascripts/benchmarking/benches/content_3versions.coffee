Benches = @Benches ||= {}

# setup a model
Benches.setupContent3 = (next) ->
  class Answer extends Backbone.Model
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

# create a data object
Benches.beforeContent3 = (next) ->
  @answerOriginal = Util.randomObject()
  @answer = new @Answer _.deepClone @answerOriginal
  next.call @

# update this object three times
Benches.content3 = (next) ->
  deleteCount  = Util.randomFrom(0, 2)
  changeCount  = Util.randomFrom(1, 4)
  createCount  = Util.randomFrom(1, 2)
  textChange   = 8
  stringChange = 3
  _.each [1..3], =>
    @answerOriginal = Util.randomVersion(@answerOriginal,
                                         deleteCount,   
                                         changeCount,   
                                         createCount,   
                                         textChange,   
                                         stringChange)
    @answer.set _.deepClone @answerOriginal
  next.call @
