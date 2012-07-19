Benches = @Benches ||= {}

Benches.setupSerializedRandom = (next) ->
  class Answer extends Backbone.Model
    versioning: 'structured_content_diff'
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

Benches.beforeSerializedRandom = (next) ->
  @answer = new @Answer @randomObject()
  @answer.set @randomVersion(@answer.attributes)
  @dummy = new @Answer @randomVersion(@answer.attributes)
  next.call @

Benches.serializedRandom = (next) ->
  try
    if @answer._applyPatchesTo @dummy
      @success = 1
    else
      @success = 0
    window.struct = JSON.stringify @dummy._sortPropertiesIn @dummy.attributes
  catch error
    console.log error
    @success = 0
  finally
    next.call @
