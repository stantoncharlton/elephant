$ ->

  update_explore = () ->
    $('#explore_loading').removeClass 'hidden'
    $('#main_chart').addClass 'hidden'

    query_string = ''
    $('.explore-value').each ->
      if $(this).val().length > 0 && $(this).attr('data-active') == 'true'
        query_string += $(this).attr('data-field') + '=' + $(this).val() + '&'

    $.ajax '/explore?' + query_string, type: 'get', dataType: 'script'

  $('.explore-value').change ->
    if $(this).attr('data-field') == 'compare'
      compare_value = $(this).val()
      $('.explore-value[data-field=option]').each ->
        if $(this).attr('data-compare') is compare_value
          $(this).attr('data-active', 'true')
          $(this).closest("div").removeClass "hidden"
        else
          $(this).attr('data-active', 'false')
          $(this).closest("div").addClass "hidden"
    if document.readyState == 'complete'
      update_explore()


  update_explore()
