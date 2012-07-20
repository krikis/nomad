Benches = @Benches ||= {}

Benches.setupSerializedRandom = (next) ->
  class Answer extends Backbone.Model
    versioning: 'structured_content_diff'
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

Benches.beforeSerializedRandom = (next) ->
  @answerOriginal = @randomObject()
  @answer = new @Answer _.deepClone @answerOriginal
  @answer.set @randomVersion(@answerOriginal)
  @dummyOriginal = @randomVersion(@answerOriginal)
  @dummy = new @Answer @dummyOriginal
  next.call @

Benches.serializedRandom = (next) ->
  try
    if @answer._applyPatchesTo @dummy
      console.log '================================= Answer ================================='
      _.each _.union(_.keys(@answerOriginal), _.keys(@answer.attributes)), (key) =>
        if @answer.attributes[key] isnt @answerOriginal[key]
          console.log "--@answer.#{key}:"
          console.log @answer.attributes[key]
          console.log "=> #{@dummy.attributes[key]}"
      console.log '================================= Dummy  ================================='
      _.each _.union(_.keys(@answerOriginal), _.keys(@dummyOriginal)), (value, key) =>
        if @dummyOriginal[key] isnt @answerOriginal[key]
          console.log "--@dummy.#{key}:"
          console.log @dummyOriginal[key]
          console.log "=> #{@dummy.attributes[key]}"
      # console.log JSON.parse JSON.stringify @answerOriginal
      # console.log JSON.parse JSON.stringify @answer.attributes
      # console.log JSON.parse JSON.stringify @dummyOriginal
      # console.log JSON.parse JSON.stringify @dummy.attributes
      @success = 1
    else
      @success = 0
    window.struct = JSON.stringify @dummy._sortPropertiesIn @dummy.attributes
  catch error
    console.log error
    @success = 0
  finally
    next.call @
