$ ->

  if $('#offshore_checkbox').is(':checked')
    $('#offshore_fields').css('display', 'inline')

  $('#offshore_checkbox').live "click", ->
    if $(this).is(':checked')
      $('#offshore_fields').css('display', 'inline')
    else
      $('#offshore_fields').css('display', 'none')
