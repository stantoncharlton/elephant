$ ->

  $('#activity_code_select').live "change", ->
    if $(this).find('option:selected').val() == '2'
      $('.survey-entry').removeClass 'hidden'
    else
      $('.survey-entry').addClass 'hidden'

    return false

  $('#drilling_log_filter').live "change", ->
    selection = $(this).find('option:selected').val()
    $('.log-entry-hidden').addClass 'hidden'
    if selection == 'recent'
      $('.log-entry-group').each ->
        $(this).hide()
      $('.log-entry-group:last').show()
      $('.log-entry-group:last').find('.log-entry-hidden').text('' + ($('.log-entry-group:last').find('.drilling-log-entry').length - 5) + ' previous entries this day...').removeClass 'hidden'
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
          $$(this).find('.drilling-log-entry').each ->
            $(this).show()
        else
          $(this).hide()
    return false

  $('#add_new_entry_jump').live "click", ->
    $("html, body").animate({ scrollTop: $(document).height() }, "fast")
    return false