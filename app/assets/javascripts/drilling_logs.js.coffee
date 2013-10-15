$ ->

  $('#activity_code_select').live "change", ->
    if $(this).find('option:selected').val() == '2'
      $('.survey-entry').removeClass 'hidden'
    else
      $('.survey-entry').addClass 'hidden'

    return false