Benches = @Benches ||= {}

Benches.TIMEOUT_INCREMENT = 10

Benches.waitsFor = (check, message, timeout, callback) ->
  @_waitFor(check, callback, message, timeout, 0)
    
Benches._waitFor = (check, callback, message, timeout, total) ->
  if check.apply(@)
    callback.apply(@) if _.isFunction(callback)
  else if total >= timeout
    console.log "Timed out afer #{total} msec waiting for #{message}!"
    return
  else
    total += @TIMEOUT_INCREMENT
    setTimeout (=>
      @_waitFor.apply(@, [check, callback, message, timeout, total])
    ), @TIMEOUT_INCREMENT
