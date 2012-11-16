$('#clearStorage').click ->
  localStorage.clear()
  
$('#clearObjects').click ->
  _.each _.properties(localStorage), (property) ->
    unless /^system_/.test property
      localStorage.removeItem(property)
  
$('#fayeServer').html(FAYE_SERVER)

$('a').click ->
  if $(this).attr('href') == '#tab5'
    window.updateSettings = setInterval (->
      $('#fayeStatus').html(window.client?.getState() || 'UNKNOWN')
      used = Math.round(JSON.stringify(localStorage).length / 26214.47)
      className = if used < 50
        'label-success'
      else if used < 75
        'label-warning'
      else
        'label-important'
      console.log className
      usedLabel = $('#localStorageSize')
      usedLabel.html("#{used}%")
      usedLabel.removeClass()
      usedLabel.addClass("label #{className}")
    ), 500
  else
    clearInterval(window.updateSettings)