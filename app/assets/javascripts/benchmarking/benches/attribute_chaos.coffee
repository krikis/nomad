Benches = @Benches ||= {}

Benches.setupAttributeChaos = (next) ->
  class Answer extends Backbone.Model
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

Benches.beforeAttributeChaos = (next) ->
  @answerOriginal = @randomObject()
  @answer = new @Answer _.deepClone @answerOriginal
  @answer.set @chaosVersion(@answerOriginal)
  @dummyOriginal = @chaosVersion(@answerOriginal)
  @dummy = new @Answer @dummyOriginal
  next.call @

Benches.attributeChaos = (next) ->
  try
    if @answer._applyPatchesTo @dummy
      @success = 1
    else
      @success = 0
    window.merge = JSON.stringify @dummy._sortPropertiesIn @dummy.attributes
  catch error
    console.log error
    @success = 0
  finally
    next.call @
