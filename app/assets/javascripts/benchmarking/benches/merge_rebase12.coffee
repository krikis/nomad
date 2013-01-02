Benches = @Benches ||= {}

Benches.setupMergeRebase12 = (next) ->
  # define a model
  class Answer extends Backbone.Model
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

Benches.beforeMergeRebase12 = (next) ->  
  # create the original data version
  @answerOriginal = Util.randomObject()
  @answer = new @Answer _.deepClone @answerOriginal
  # specify the amount of random change
  deleteCount  = Util.randomFrom(0, 1)
  changeCount  = Util.randomFrom(1, 2)
  createCount  = Util.randomFrom(0, 1)
  textChange   = 4
  stringChange = 1
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

Benches.mergeRebase12 = (next) ->
  # resolve the conflicts
  @success = @answer._applyPatchesTo @dummy
  next.call @