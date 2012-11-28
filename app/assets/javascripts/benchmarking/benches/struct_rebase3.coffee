Benches = @Benches ||= {}

Benches.setupStructRebase3 = (next) ->
  class Answer extends Backbone.Model
    versioning: 'structured_content_diff'
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

Benches.beforeStructRebase3 = (next) ->
  # instantiate a data object with outdated data
  @answerOriginal = Util.randomObject()
  @answer = new @Answer _.deepClone @answerOriginal
  # specify the amount of random change
  deleteCount  = Util.randomFrom(1, 3)
  changeCount  = Util.randomFrom(4, 8)
  createCount  = Util.randomFrom(1, 3)
  textChange   = 15
  stringChange = 5
  # instantiate a data object with up to date data
  @upToDate = Util.randomVersion(_.deepClone(@answerOriginal),
                                 deleteCount,   
                                 changeCount,   
                                 createCount,   
                                 textChange,   
                                 stringChange)
  @dummy = new @Answer @upToDate
  # perform a number of conflicting updates
  _.each [1..3], =>
    @answerOriginal = Util.randomVersion(@answerOriginal,
                                         deleteCount,   
                                         changeCount,   
                                         createCount,   
                                         textChange,   
                                         stringChange)
    @answer.set _.deepClone @answerOriginal
  next.call @

Benches.structRebase3 = (next) ->
  @answer._applyPatchesTo @dummy
  window.struct = JSON.stringify @dummy._sortPropertiesIn @dummy.attributes
  next.call @