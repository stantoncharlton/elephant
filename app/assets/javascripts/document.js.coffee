$ ->

  delay = (time, fn) ->
    setTimeout fn, time

  $('.download-link').live "click", ->
    $(this).closest('.document-download-message').popover('show')
    link = $(this)
    delay 2000, ->
      link.closest('.document-download-message').popover('hide')
