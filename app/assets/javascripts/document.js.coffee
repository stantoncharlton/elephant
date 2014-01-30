$ ->

  delay = (time, fn) ->
    setTimeout fn, time

  $('.download-link').live "click", ->
    $(this).closest('.document-download-message').popover('show')
    link = $(this)
    delay 2000, ->
      link.closest('.document-download-message').popover('hide')


  $('#download_all_post_job').live "click", ->
    $('#documents2').find('.download-link').each ->
      if $(this).attr('href') != ''
        alert('hello')
        $(this).multiDownload()
    return false