$('#clearStorage').click ->
  localStorage.clear()
  
$('#clearObjects').click ->
  _.each _.properties(localStorage), (property) ->
    unless /^system_/.test property
      localStorage.removeItem(property)
      
$('#fayeServer').html(FAYE_SERVER).addClass('label-info') 

# update localStorage info
updateLocalStorageUsage = (htmlId)->
  used = Math.round(JSON.stringify(localStorage).length / 26214.47)
  className = if used < 50
    'label-success'
  else if used < 75
    'label-warning'
  else
    'label-important'
  usedLabel = $("##{htmlId}")
  usedLabel.html("#{used}%")
  usedLabel.removeClass()
  usedLabel.addClass("label #{className}")

# update faye client state
updateFayeStatus = (fayeClient, htmlId)->
  state = fayeClient?.getState() || 'UNKNOWN'
  stateElement = $("##{htmlId}")
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
updateFayeClientId = (fayeClient, htmlId)->  
  fayeId =  fayeClient?.getClientId() || 'UNKNOWN'
  fayeIdElement = $("##{htmlId}")
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
  

$('a').click ->
  if $(this).attr('href') == '#tab5'
    window.updateSettings = setInterval (->
      # update localstorage usage
      updateLocalStorageUsage('localStorageSize')
      # update faye client info
      updateFayeStatus(window.client, 'fayeStatus')
      updateFayeClientId(window.client, 'fayeClientId')
      updateFayeStatus(window.secondClient, 'secondFayeStatus')
      updateFayeClientId(window.secondClient, 'secondFayeClientId')
    ), 500
  else
    clearInterval(window.updateSettings)