$ ->

  delay = (time, fn) ->
    setTimeout fn, time

  $('.download-link').on "click", ->
    popover = $(this).closest('.document-download-message')
    #popover.popover('show')
    #delay 1000, ->
    #  popover.popover('toggle')


  $('#download_all_post_job').on "click", ->
    $('#documents2').find('.download-link').each ->
      if $(this).attr('href') != ''
        alert('hello')
        $(this).multiDownload()
    return false