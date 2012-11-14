$('#clearStorage').click ->
  localStorage.clear()
$('#fayeServer').html(FAYE_SERVER)

$('a').click ->
  if $(this).attr('href') == '#tab5'
    window.updateSettings = setInterval (->
      $('#fayeStatus').html(window.client?.getState())
      $('#localStorageSize').html("#{Math.round(JSON.stringify(localStorage).length / 26000)}%")
    ), 500
  else
    clearInterval(window.updateSettings)