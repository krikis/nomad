Benches = @Benches ||= {}

# setup data model
Benches.setupMergeAddVersion25 = (next) ->
  class Answer extends Backbone.Model
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

# create data object
Benches.beforeMergeAddVersion25 = (next) ->
  @answerOriginal = Util.randomObject()
  @answer = new @Answer _.deepClone @answerOriginal
  next.call @

# perform update on data object
Benches.mergeAddVersion25 = (next) ->
  # specify the amount of random change
  deleteCount  = Util.randomFrom(0, 2)
  changeCount  = Util.randomFrom(1, 4)
  createCount  = Util.randomFrom(1, 2)
  textChange   = 8
  stringChange = 3
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