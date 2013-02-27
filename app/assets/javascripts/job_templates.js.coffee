
$ ->

  $('.job-template-name').change ->
    $(this).closest('form').submit()

  $('.job-template-description').change ->
    $(this).closest('form').submit()


  $('form').on 'click', '.remove_fields', (event) ->
    $(this).prev('input[type=hidden]').val('1')
    $(this).closest('fieldset').hide()
    event.preventDefault()

  $('form').on 'click', '.add_fields', (event) ->

    $('#browse_upload').click()

    time = new Date().getTime()
    regexp = new RegExp($(this).data('id'), 'g')
    $(this).before($(this).data('fields').replace(regexp, time))

    event.preventDefault()

  $('.document-upload-button').live "click", ->
    $(event.target).prev().trigger "click"
    return false

  $('.document-upload-button').live "hover", ->
    $(this).css('cursor','hand');

  $('.job-type-tray-toggle').click ->
    $('.tray').addClass 'hidden'
    $('.job-type-tray-toggle').closest('li').removeClass 'active'
    tray = $(this).attr 'data-tray'
    $(".tray[data-tray=" + tray + "]").removeClass 'hidden'
    $(this).closest('li').addClass 'active'
    document.location.hash = tray;
    return false

    $(".custom-data-toggle[data-tray=" + document.location.hash.replace('#', '') + "]").trigger "click"
