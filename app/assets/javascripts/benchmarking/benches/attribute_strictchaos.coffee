Benches = @Benches ||= {}

Benches.setupAttributeStrictChaos = (next) ->
  class Answer extends Backbone.Model
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

Benches.beforeAttributeStrictChaos = (next) ->
  @answerOriginal = @randomObject()
  @answer = new @Answer _.deepClone @answerOriginal
  @answer.set @randomVersion(@answerOriginal)
  @dummyOriginal = @randomVersion(@answerOriginal)
  @dummy = new @Answer _.deepClone @dummyOriginal
  next.call @

Benches.attributeStrictChaos = (next) ->
  try
    if @answer._applyPatchesTo @dummy
      @success = 1
    else  
      console.log 'Patching failed!!!'
      @success = 0
    console.log '================================= Attribute  ================================='
    _.each _.union(_.keys(@answerOriginal),
                   _.keys(@dummyOriginal),
                   _.keys(@answer.attributes)), (key) =>
      if not _.isEqual(@answer.attributes[key], @answerOriginal[key]) or
         not _.isEqual(@dummyOriginal[key],     @answerOriginal[key])
        if not _.isEqual(@answer.attributes[key], @answerOriginal[key]) and
           not _.isEqual(@answer.attributes[key], @dummyOriginal[key]) and
           _.isEqual(@dummyOriginal[key], @dummy.attributes[key])
          console.error "--#{key}:"
          @success = 0
        else if not _.isEqual(@answer.attributes[key], @answerOriginal[key]) and
                not _.isEqual(@dummyOriginal[key],     @answerOriginal[key])
          merge = true
          console.warn "--#{key}:"
        else
          console.log "--#{key}:"
        if _.isString(@answerOriginal[key]) and ' ' in @answerOriginal[key]
          if merge and
             _.isString(@answer.attributes[key]) and ' ' in @answer.attributes[key] and
             _.isString(@dummyOriginal[key]    ) and ' ' in @dummyOriginal[key]
            dmp = new diff_match_patch 
            diff1 = dmp.diff_main @answerOriginal[key], @answer.attributes[key]
            dmp.diff_cleanupSemantic diff1
            diff2 = dmp.diff_main @answerOriginal[key], @dummyOriginal[key]
            dmp.diff_cleanupSemantic diff2
            diff3 = dmp.diff_main @answerOriginal[key], @dummy.attributes[key]
            dmp.diff_cleanupSemantic diff3
            well = $("<div class='well'>")
            well.append $("#{dmp.diff_prettyHtml diff1}<hr />")
            well.append $("#{dmp.diff_prettyHtml diff2}<hr />")
            well.append $("#{dmp.diff_prettyHtml diff3}")
            box = $("<div class='box'>")
            box.append well
            $('#tab4 #attr').append box
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
    window.merge = JSON.stringify @dummy._sortPropertiesIn @dummy.attributes
  catch error
    console.log error.stack
    window.errors ||= []
    window.errors.push error
    @success = 0
  finally
    next.call @
