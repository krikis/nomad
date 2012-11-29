Benches = @Benches ||= {}

Benches.setupAttribute50 = (next) ->
  # define model
  class Answer extends Backbone.Model
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

Benches.beforeAttribute50 = (next) ->
  # create the original data object
  @answerOriginal = Util.randomObject()
  @answer = new @Answer _.deepClone @answerOriginal
  # specify the amount of random change
  deleteCount  = Util.randomFrom(1, 3)
  changeCount  = Util.randomFrom(4, 8)
  createCount  = Util.randomFrom(1, 3)
  textChange   = 15
  stringChange = 5
  # perform the winning update
  [@dummyOriginal, deleted] = Util.randomVersion(@answerOriginal,
                                                 deleteCount,   
                                                 changeCount,   
                                                 createCount,   
                                                 textChange,   
                                                 stringChange)
  @dummy = new @Answer _.deepClone @dummyOriginal
  # perform the losing update
  [version, deleted] = Util.randomVersion(@answerOriginal,
                                          deleteCount,   
                                          changeCount,   
                                          createCount,   
                                          textChange,   
                                          stringChange)
  @answer.set version
  _.each deleted, (property)=>
    @answer.unset property
  next.call @

Benches.attribute50 = (next) ->
  try
    # resolve the conflict
    if @answer._applyPatchesTo @dummy
      @success = 1
      # console.log '================================= Attribute  ================================='
      _.each _.union(_.properties(@answerOriginal),
                     _.properties(@dummyOriginal),
                     _.properties(@answer.attributes)), (key) =>
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
              $('#tab4 #attr').append box
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
