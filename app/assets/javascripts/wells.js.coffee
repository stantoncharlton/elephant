$ ->

  $('.map-latlong-text-entry').live "keyup", ->
    if $(this).val().length > 0
      $('.map-latlong-link').removeClass 'hidden'
    else
      $('.map-latlong-link').addClass 'hidden'

  $('.map-latlong-link').live "click", ->
    $(this).attr 'href', 'http://maps.google.com/maps?z=10&q=' + $('.map-latlong-text-entry').val()

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

    count = 0
    $('.job-link').each ->
      id = $(this).attr("id").replace('division_', '')
      if division == '0' || id == division
        $(this).show()
        count = count + 1
      else
        $(this).hide()

    $('#jobs_count_container').removeClass 'hidden'
    $('#jobs_count').text(count)




