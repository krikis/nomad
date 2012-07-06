@BenchTools =
  TIMEOUT_INCREMENT: 10

  waitsFor: (check, message, timeout, callback) ->
    @_waitFor(check, callback, message, timeout, 0)
    
  _waitFor: (check, callback, message, timeout, total) ->
    if check.apply(@)
      callback.apply(@) if _.isFunction(callback)
    else if total >= timeout
      console.log "Timed out afer #{total} msec waiting for #{message}!"
      return
    else
      total += @TIMEOUT_INCREMENT
      setTimeOut (=>
        @_waitFor.apply(@, check, callback, message, timeout, total)
      ), @TIMEOUT_INCREMENT
