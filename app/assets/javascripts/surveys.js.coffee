$ ->

  $('#import_tie_on').on "click", ->
    if $(this).is(':checked')
      $('#tie_on_fields').addClass "hidden"
    else
      $('#tie_on_fields').removeClass "hidden"
