Benches = @Benches ||= {}

Benches.setupMergeRebase6 = (next) ->
  class Answer extends Backbone.Model
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

Benches.beforeMergeRebase6 = (next) ->
  # instantiate a data object with outdated data
  @answerOriginal = Util.randomObject()
  @answer = new @Answer _.deepClone @answerOriginal
  # instantiate a data object with up to date data
  deleteCount  = Util.randomFrom(0, 2)
  changeCount  = Util.randomFrom(1, 4)
  createCount  = Util.randomFrom(1, 2)
  textChange   = 8
  stringChange = 3
  @upToDate = Util.randomVersion(_.deepClone(@answerOriginal),
                                 deleteCount,   
                                 changeCount,   
                                 createCount,   
                                 textChange,   
                                 stringChange)
  @dummy = new @Answer @upToDate
  # perform a number of conflicting updates
  _.each [1..6], =>
    @answerOriginal = Util.randomVersion(@answerOriginal,
                                         deleteCount,   
                                         changeCount,   
                                         createCount,   
                                         textChange,   
                                         stringChange)
    @answer.set _.deepClone @answerOriginal
  next.call @

Benches.mergeRebase6 = (next) ->
  @answer._applyPatchesTo @dummy
  window.merge = JSON.stringify @dummy._sortPropertiesIn @dummy.attributes
  next.call @