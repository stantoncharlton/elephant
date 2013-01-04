$ ->

  if $('#offshore_checkbox').is(':checked')
    $('#offshore_fields').css('display', 'inline')

  $('#offshore_checkbox').live "click", ->
    if $(this).is(':checked')
      $('#offshore_fields').css('display', 'inline')
    else
      $('#offshore_fields').css('display', 'none')


  $('.wellUnitsSelect').change ->
    $.ajax '/wells/' + $('.wellIdentifier').attr("id") + "?" + $(this).attr("id").replace("well_", "") + '=' + $(this).val(), type: 'put', dataType: 'script'