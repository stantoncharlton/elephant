$ ->

  $('#activity_code_select').live "change", ->
    #if $(this).find('option:selected').val() == '4'
    #  $('.survey-entry').removeClass 'hidden'
    #else
    #  $('.survey-entry').addClass 'hidden'
    return false


  $('#drilling_log_filter').live "change", ->
    selection = $(this).find('option:selected').val()
    $('.log-entry-hidden').addClass 'hidden'
    if selection == 'recent'
      $('.log-entry-group').each ->
        $(this).hide()
      $('.log-entry-group:last').show()
      count = $('.log-entry-group:last').find('.drilling-log-entry').length - 5
      if count < 0
        count = 0
      $('.log-entry-group:last').find('.log-entry-hidden').text('' + (count) + ' previous entries this day...').removeClass 'hidden'
      $('.log-entry-group:last').find('.drilling-log-entry').each ->
        $(this).hide()
      $('.log-entry-group:last').find('.drilling-log-entry').slice(-5).each ->
        $(this).show()
    else if selection == 'all'
      $('.log-entry-group').each ->
        $(this).show()
      $('.drilling-log-entry').each ->
        $(this).show()
    else
      $('.log-entry-group').each ->
        if $(this).attr('data-date') == selection
          $(this).show()
          $(this).find('.drilling-log-entry').each ->
            $(this).show()
        else
          $(this).hide()
    return false

  $('#add_new_entry_jump').live "click", ->
    $("html, body").animate({ scrollTop: $(document).height() }, "fast")
    return false

  if $('#checkbox_override_date').is(':checked')
    $('.date-fields').removeClass 'hidden'

  $('.toggle-content-link').live "click", ->

    content = $(this).next('.toggle-content')
    if content.length > 0
      if content.hasClass 'hidden'
        content.removeClass 'hidden'
      else
        content.addClass 'hidden'
    return false