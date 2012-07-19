Benches = @Benches ||= {}

Benches.setupAttributeChaos = (next) ->
  class Answer extends Backbone.Model
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

Benches.beforeAttributeChaos = (next) ->
  @answer = new @Answer @randomObject()
  @answer.set @chaosVersion(@answer.attributes)
  @dummy = new @Answer @chaosVersion(@answer.attributes)
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
