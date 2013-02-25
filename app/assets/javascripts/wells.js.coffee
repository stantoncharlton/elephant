$ ->

  if $('#offshore_checkbox').is(':checked')
    $('#offshore_fields').css('display', 'inline')

  $('#offshore_checkbox').live "click", ->
    if $(this).is(':checked')
      $('#offshore_fields').css('display', 'inline')
    else
      $('#offshore_fields').css('display', 'none')

  $('#expand_well_details').click ->
    $('#expand_well_details').hide()
    $('.well-details').removeClass 'hidden'
    return false

  $('.custom-select').change ->
    division = $(this).val()

    $('.job-link').each ->
      id = $(this).attr("id").replace('division_', '')
      if division == '0' || id == division
        $(this).show()
      else
        $(this).hide()

