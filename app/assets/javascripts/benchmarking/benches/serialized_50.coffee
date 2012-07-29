Benches = @Benches ||= {}

Benches.setupSerialized50 = (next) ->
  class Answer extends Backbone.Model
    versioning: 'structured_content_diff'
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

Benches.beforeSerialized50 = (next) ->
  @answerOriginal = @randomObject()
  @answer = new @Answer _.deepClone @answerOriginal
  deleteCount  = @randomFrom(1, 3)
  changeCount  = @randomFrom(4, 8)
  createCount  = @randomFrom(1, 3)
  textChange   = 15
  stringChange = 5
  @answer.set @randomVersion(@answerOriginal,
                             deleteCount,   
                             changeCount,   
                             createCount,   
                             textChange,   
                             stringChange)
  @dummyOriginal = @randomVersion(@answerOriginal,
                                  deleteCount,   
                                  changeCount,   
                                  createCount,   
                                  textChange,   
                                  stringChange)
  @dummy = new @Answer _.deepClone @dummyOriginal
  next.call @

Benches.serialized50 = (next) ->
  try
    if @answer._applyPatchesTo @dummy
      @success = 1
      # console.log '================================= Serialized ================================='
      _.each _.union(_.keys(@answerOriginal),
                     _.keys(@dummyOriginal),
                     _.keys(@answer.attributes)), (key) =>
        if not _.isEqual(@answer.attributes[key], @answerOriginal[key]) or
           not _.isEqual(@dummyOriginal[key],     @answerOriginal[key])
          if not _.isEqual(@answer.attributes[key], @answerOriginal[key]) and
             not _.isEqual(@answer.attributes[key], @dummyOriginal[key]) and
             _.isEqual(@dummyOriginal[key], @dummy.attributes[key])
            # console.error "--#{key}:"
          else if not _.isEqual(@answer.attributes[key], @answerOriginal[key]) and
                  not _.isEqual(@dummyOriginal[key],     @answerOriginal[key])
            merge = true
            # console.warn "--#{key}:"
          else
            # console.log "--#{key}:"
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
              well.append $("<h3><small>Remote Changes</small></h3>")
              well.append $("#{dmp.diff_prettyHtml diff2}")
              well.append $("<h3><small>Local Changes</small></h3>")
              well.append $("#{dmp.diff_prettyHtml diff1}")
              well.append $("<h3><small>Merged Changes</small></h3>")
              well.append $("#{dmp.diff_prettyHtml diff3}")
              box = $("<div class='box'>")
              box.append well
              $('#tab4 #seri').append box
            # console.log "#{@answerOriginal[key]}"
            # console.log "-dum-> #{@dummyOriginal[key]}"
            # console.log "-ans-> #{@answer.attributes[key]}"
            # console.log "=mrg=> #{@dummy.attributes[key]}"
          else
            original = @answerOriginal[key]
            padding = Array("#{original}".length + 1).join(' ')
            # console.log "#{padding } -dum-> #{@dummyOriginal[key]    }"
            # console.log "#{original} -ans-> #{@answer.attributes[key]}"
            # console.log "#{padding } =mrg=> #{@dummy.attributes[key] }"
    else  
      # console.log 'Patching failed!!!'
      @success = 0
  catch error
    # console.error error.message
    # console.log error.stack
    @success = 0
  finally
    next.call @
