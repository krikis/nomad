Benches = @Benches ||= {}

# setup data model
Benches.setupMergeAddVersion12 = (next) ->
  class Answer extends Backbone.Model
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

# create data object
Benches.beforeMergeAddVersion12 = (next) ->
  @answerOriginal = Util.randomObject()
  @answer = new @Answer _.deepClone @answerOriginal
  next.call @

# perform update on data object
Benches.mergeAddVersion12 = (next) ->
  # specify the amount of random change
  deleteCount  = Util.randomFrom(0, 1)
  changeCount  = Util.randomFrom(1, 2)
  createCount  = Util.randomFrom(0, 1)
  textChange   = 4
  stringChange = 1
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