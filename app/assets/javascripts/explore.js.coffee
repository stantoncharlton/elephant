$ ->

  update_explore = () ->
    $('#explore_loading').removeClass 'hidden'
    $('#main_chart').addClass 'hidden'

    query_string = ''
    $('.explore-value').each ->
      if $(this).val().length > 0
        query_string += $(this).attr('data-field') + '=' + $(this).val() + '&'

    $.ajax '/explore?' + query_string, type: 'get', dataType: 'script'

  $('.explore-value').change ->
    if document.readyState == 'complete'
      update_explore()

  update_explore()
