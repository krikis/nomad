Benches = @Benches ||= {}

Benches.setupResolution = (next, options = {}) ->
  class Answer extends Backbone.Model
    versioning: options.versioning
    collection:
      url: '/some/url'
  @Answer = Answer
  next.call @

Benches.beforeResolution = (next, options = {}) ->
  # create the original data version
  @originalVersion = Util.randomObject(typeOdds: options.typeOdds)
  # handle local update
  [@localVersion, localDeleted] = Util.randomVersion(@originalVersion,
                                                     change: options.changeRate,
                                                     changeOdds: options.changeOdds)
  @localAnswer = new @Answer _.deepClone @originalVersion
  @localAnswer.set @localVersion
  _.each localDeleted, (property)=>
    @localAnswer.unset property
  if @originalVersion.versioning == 'structured_content_diff'
    @localDummy = new @Answer _.deepClone @localVersion
  # handle remote update
  [@remoteVersion, remoteDeleted] = Util.randomVersion(@originalVersion,
                                                       change: options.changeRate,
                                                       changeOdds: options.changeOdds)
  @remoteDummy = new @Answer _.deepClone @remoteVersion
  if @originalVersion.versioning == 'structured_content_diff'
    @remoteAnswer = new @Answer _.deepClone @originalVersion
    @remoteAnswer.set @remoteVersion
    _.each remoteDeleted, (property)=>
      @remoteAnswer.unset property
  next.call @

Benches.resolution = (next, options = {}) ->
  @context.lastRun ||= 1
  @context.json ||= 0
  @context.failure ||= 0
  try
    if @success = @localAnswer._applyPatchesTo @remoteDummy
      @dummy = @remoteDummy
      @reversePatch = @localAnswer._versioning?.reversePatch
  catch error
    @success = false
    if error.name == 'SyntaxError'
      @context.json += 1
      @suite?.log "JSON format broken!"
    else
      @suite?.log error.message
      @suite?.log error.stack

  # apply patches in reverse order when patching fails
  if not @success and @remoteAnswer?
    try
      if @success = @remoteAnswer._applyPatchesTo @localDummy
        @dummy = @localDummy
        @reversePatch = true
    catch error
      @success = false
      if error.name == 'SyntaxError'
        @context.json += 1
        @suite?.log "JSON format broken!"
      else
        @suite?.log error.message
        @suite?.log error.stack

  if @success
    # console.log '================================= Serialized ================================='
    _.each _.union(_.properties(@originalVersion),
                   _.properties(@remoteVersion),
                   _.properties(@localVersion)), (key) =>
      if not _.isEqual(@localVersion[key], @originalVersion[key]) or
         not _.isEqual(@remoteVersion[key], @originalVersion[key])
        if not _.isEqual(@localVersion[key], @originalVersion[key]) and
           not _.isEqual(@localVersion[key], @remoteVersion[key]) and
           _.isEqual(@remoteVersion[key], @dummy.attributes[key])
          # console.error "--#{key}:"
        else if not _.isEqual(@localVersion[key], @originalVersion[key]) and
                not _.isEqual(@remoteVersion[key], @originalVersion[key])
          merge = true
          # console.warn "--#{key}:"
        else
          # console.log "--#{key}:"
        if _.isString(@originalVersion[key]) and ' ' in @originalVersion[key]
          if merge and
             _.isString(@localVersion[key]) and ' ' in @localVersion[key] and
             _.isString(@remoteVersion[key]) and ' ' in @remoteVersion[key]
            dmp = new diff_match_patch
            diff1 = dmp.diff_main @originalVersion[key], @localVersion[key]
            dmp.diff_cleanupSemantic diff1
            diff2 = dmp.diff_main @originalVersion[key], @remoteVersion[key]
            dmp.diff_cleanupSemantic diff2
            diff3 = dmp.diff_main @originalVersion[key], @dummy.attributes[key]
            dmp.diff_cleanupSemantic diff3
            well = $("<div class='well'>")
            well.append $("<h3><small>Remote Changes</small></h3>")
            well.append $("#{dmp.diff_prettyHtml diff2}")
            well.append $("<h3><small>Local Changes</small></h3>")
            well.append $("#{dmp.diff_prettyHtml diff1}")
            well.append $("<h3><small>Merged Changes</small></h3>")
            well.append $("#{dmp.diff_prettyHtml diff3}")
            box = $("<div class='box'>")
            if @reversePatch
              box.addClass('reverse')
            box.append well
            if @dummy.versioning == 'structured_content_diff'
              $('#tab4 #seri').append box
            else
              $('#tab4 #attr').append box
          # console.log "#{@originalVersion[key]}"
          # console.log "-dum-> #{@remoteVersion[key]}"
          # console.log "-ans-> #{@localVersion[key]}"
          # console.log "=mrg=> #{@dummy.attributes[key]}"
        else
          original = @originalVersion[key]
          padding = Array("#{original}".length + 1).join(' ')
          # console.log "#{padding } -dum-> #{@remoteVersion[key]    }"
          # console.log "#{original} -ans-> #{@localVersion[key]}"
          # console.log "#{padding } =mrg=> #{@dummy.attributes[key] }"
  else
    if @dummy?.versioning == 'structured_content_diff'
      @context.failure += 1
    # console.log 'Patching failed!!!'
  if @context.lastRun < @context.runs and @context.failure > 0
    @context.log "[#{@context.runs}] Invalid Data: #{(@context.json / @context.failure) * 100}%"
    @context.lastRun = @context.runs
  next.call @