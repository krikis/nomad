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
      $('#fayeStatus').html(window.client?.getState())
      $('#localStorageSize').html("#{Math.round(JSON.stringify(localStorage).length / 26214.47)}%")
    ), 500
  else
    clearInterval(window.updateSettings)