Benches = @Benches ||= {}

Benches.setupStructRebase50 = (next) ->
  # define a model
  class Answer extends Backbone.Model
    versioning: 'structured_content_diff'
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

Benches.beforeStructRebase50 = (next) ->  
  # create the original data version
  @answerOriginal = Util.randomObject()
  @answer = new @Answer _.deepClone @answerOriginal
  # specify the amount of random change
  deleteCount  = Util.randomFrom(1, 3)
  changeCount  = Util.randomFrom(4, 8)
  createCount  = Util.randomFrom(1, 3)
  textChange   = 15
  stringChange = 5
  # perform the winning update
  [dummyVersion, deleted] = Util.randomVersion(@answerOriginal,
                                               deleteCount,   
                                               changeCount,   
                                               createCount,   
                                               textChange,   
                                               stringChange)
  @dummy = new @Answer _.deepClone dummyVersion
  # perform the losing update
  [version, deleted] = Util.randomVersion(@answerOriginal,
                                          deleteCount,   
                                          changeCount,   
                                          createCount,   
                                          textChange,   
                                          stringChange)
  @answer.set version
  _.each deleted, (property)=>
    @answer.unset property
  next.call @

Benches.structRebase50 = (next) ->
  # resolve the conflicts
  @success = @answer._applyPatchesTo @dummy
  next.call @