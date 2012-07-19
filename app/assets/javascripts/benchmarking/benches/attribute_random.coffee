Benches = @Benches ||= {}

Benches.setupAttributeRandom = (next) ->
  class Answer extends Backbone.Model
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

Benches.beforeAttributeRandom = (next) ->
  @answer = new @Answer @randomObject()
  @answer.set @randomVersion(@answer.attributes)
  @dummy = new @Answer @randomVersion(@answer.attributes)
  next.call @

Benches.attributeRandom = (next) ->
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
