$('#clearStorage').click ->
  localStorage.clear()
  
$('#clearObjects').click ->
  _.each _.properties(localStorage), (property) ->
    unless /^system_/.test property
      localStorage.removeItem(property)
  
$('#clientId').html(Nomad.clientId || 'UNKNOWN').addClass('label-info')
$('#fayeServer').html(FAYE_SERVER).addClass('label-info') 

$('a').click ->
  if $(this).attr('href') == '#tab5'
    window.updateSettings = setInterval (->
      # update localstorage usage
      used = Math.round(JSON.stringify(localStorage).length / 26214.47)
      className = if used < 50
        'label-success'
      else if used < 75
        'label-warning'
      else
        'label-important'
      usedLabel = $('#localStorageSize')
      usedLabel.html("#{used}%")
      usedLabel.removeClass()
      usedLabel.addClass("label #{className}")
      # update faye client state
      state = window.client?.getState() || 'UNKNOWN'
      stateElement = $('#fayeStatus')
      stateElement.removeClass()
      switch state
        when 'UNKNOWN'
          stateElement.addClass("label")
        when 'CONNECTING'
          stateElement.addClass("label label-info")
        when 'CONNECTED'
          stateElement.addClass("label label-success")
        when 'DISCONNECTED'
          stateElement.addClass("label label-important")
      stateElement.html(state)
      # update faye client id
      fayeId =  window.client?.getClientId() || 'UNKNOWN'
      fayeIdElement = $('#fayeId')
      if fayeIdElement.html() != fayeId
        fayeIdElement.fadeOut 'fast', ->
          fayeIdElement.removeClass()
          if fayeId == 'UNKNOWN'
            fayeIdElement.addClass("label")
          else
            fayeIdElement.addClass("label label-info")
          fayeIdElement.html(fayeId)
          fayeIdElement.fadeIn 'fast'
      else
        fayeIdElement.html(fayeId)
    ), 500
  else
    clearInterval(window.updateSettings)