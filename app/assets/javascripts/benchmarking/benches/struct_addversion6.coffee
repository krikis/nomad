Benches = @Benches ||= {}

Benches.setupStructAddVersion6 = (next) ->
  class Answer extends Backbone.Model
    versioning: 'structured_content_diff'
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

Benches.beforeStructAddVersion6 = (next) ->
  @answerOriginal = Util.randomObject()
  @answer = new @Answer _.deepClone @answerOriginal
  next.call @

Benches.structAddVersion6 = (next) ->  
  # specify the amount of random change
  deleteCount  = Util.randomFrom(1, 3)
  changeCount  = Util.randomFrom(4, 8)
  createCount  = Util.randomFrom(1, 3)
  textChange   = 15
  stringChange = 5
  _.each [1..6], =>
    @answerOriginal = Util.randomVersion(@answerOriginal,
                                         deleteCount,   
                                         changeCount,   
                                         createCount,   
                                         textChange,   
                                         stringChange)
    @answer.set _.deepClone @answerOriginal
  next.call @
