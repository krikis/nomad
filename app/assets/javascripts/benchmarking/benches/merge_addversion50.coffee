Benches = @Benches ||= {}

# setup data model
Benches.setupMergeAddVersion50 = (next) ->
  class Answer extends Backbone.Model
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

# create data object
Benches.beforeMergeAddVersion50 = (next) ->
  @answerOriginal = Util.randomObject()
  @answer = new @Answer _.deepClone @answerOriginal
  next.call @

# perform update on data object
Benches.mergeAddVersion50 = (next) ->
  # specify the amount of random change
  deleteCount  = Util.randomFrom(1, 3)
  changeCount  = Util.randomFrom(4, 8)
  createCount  = Util.randomFrom(1, 3)
  textChange   = 15
  stringChange = 5
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