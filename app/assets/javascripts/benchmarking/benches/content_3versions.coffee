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
  @answerVersion = _.deepClone @answerOriginal
  @answer = new @Answer _.deepClone @answerOriginal
  next.call @

# update this object three times
Benches.content3 = (next) ->
  deleteCount  = Util.randomFrom(0, 2)
  changeCount  = Util.randomFrom(4, 8)
  createCount  = Util.randomFrom(0, 2)
  textChange   = 15
  stringChange = 5
  _.each [1..3], =>
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
