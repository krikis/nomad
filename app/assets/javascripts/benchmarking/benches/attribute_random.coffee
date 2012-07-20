Benches = @Benches ||= {}

Benches.setupAttributeRandom = (next) ->
  class Answer extends Backbone.Model
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

Benches.beforeAttributeRandom = (next) ->
  @answerOriginal = @randomObject()
  @answer = new @Answer _.deepClone @answerOriginal
  @answer.set @randomVersion(@answerOriginal)
  @dummyOriginal = @randomVersion(@answerOriginal)
  @dummy = new @Answer _.deepClone @dummyOriginal
  next.call @

Benches.attributeRandom = (next) ->
  try
    if @answer._applyPatchesTo @dummy
      console.log '================================= Changes ================================='
      _.each _.union(_.keys(@answerOriginal),
                     _.keys(@dummyOriginal),
                     _.keys(@answer.attributes)), (key) =>
        if not _.isEqual(@answer.attributes[key], @answerOriginal[key]) or
           not _.isEqual(@dummyOriginal[key],     @answerOriginal[key])
          if not _.isEqual(@answer.attributes[key], @answerOriginal[key]) and
             not _.isEqual(@answer.attributes[key], @dummy.attributes[key])
            console.error "--#{key}:"
          else if not _.isEqual(@answer.attributes[key], @answerOriginal[key]) and
                  not _.isEqual(@dummyOriginal[key],     @answerOriginal[key])
            console.warn "--#{key}:"
          else
            console.log "--#{key}:"
          if _.isString(@answerOriginal[key]) and ' ' in @answerOriginal[key]
            console.log "#{@answerOriginal[key]}"
            console.log "-ans-> #{@answer.attributes[key]}"
            console.log "-dum-> #{@dummyOriginal[key]}"
            console.log "=mrg=> #{@dummy.attributes[key]}"
          else
            original = @answerOriginal[key]
            padding = Array("#{original}".length + 1).join(' ')
            console.log "#{original} -ans-> #{@answer.attributes[key]}"
            console.log "#{padding } -dum-> #{@dummyOriginal[key]    }"
            console.log "#{padding } =mrg=> #{@dummy.attributes[key] }"
      @success = 1
    else
      @success = 0
    window.merge = JSON.stringify @dummy._sortPropertiesIn @dummy.attributes
  catch error
    console.log error
    @success = 0
  finally
    next.call @
