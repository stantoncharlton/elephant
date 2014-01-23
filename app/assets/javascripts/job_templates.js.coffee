
$ ->

  $('.job-template-name').keyup ->
    $('#save_job_name_description').removeClass 'hidden'

  $('.job-template-name').change ->
    $(this).closest('form').submit()
    $('#save_job_name_description').addClass 'hidden'

  $('.job-template-description').keyup ->
    $('#save_job_name_description').removeClass 'hidden'

  $('.job-template-description').change ->
    $(this).closest('form').submit()
    $('#save_job_name_description').addClass 'hidden'

  $('#save_job_name_description').click ->
    $('.job-template-name').closest('form').submit()
    $('.job-template-description').closest('form').submit()
    $('#save_job_name_description').addClass 'hidden'


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
    if $.browser.mozilla
      $(this).prev().removeClass 'file-input'
      $(this).prev().trigger "click"
      $(this).prev().addClass 'file-input'
    else
      $(this).prev().trigger "click"
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

  if document.location.hash != ''
    $(".job-type-tray-toggle[data-tray=" + document.location.hash.replace('#', '') + "]").trigger "click"

  $('.show-modal-button').live "click", ->
    if $('#map').length > 0
      $('#map').hide()
    $('#modal_popup').css('visibility', 'visible')
    inner = $('#modal_popup').find('.modal-popup')
    inner.css('margin-top', 100)
    #if $(this).position().top > 380
    #  inner.css('margin-top', $(this).position().top - 300)
    #else
    #  inner.css('margin-top', $(this).position().top - 300)
    $('#modal_popup').height($(document).height() + 100)
    $('#modal_popup').find('.loading').removeClass 'hidden'
    return false

  $('.show-modal-button2').live "click", ->
    $('#modal_popup2').css('visibility', 'visible')
    inner = $('#modal_popup2').find('.modal-popup')
    inner.css('margin-top', 100)
    $('#modal_popup2').height($(document).height() + 100)
    $('#modal_popup2').find('.loading').removeClass 'hidden'
    return false

  $('.add-new-document-button').live "click", ->
    $('#new_documents_added').removeClass 'hidden'
    oldValue = $('#new_documents_added_names').text()
    if oldValue == ''
      $('#new_documents_added_names').text($(this).closest('.inline-form').find('[id=new_document_name]').val())
    else
      $('#new_documents_added_names').text(oldValue + ', ' +  $(this).closest('.inline-form').find('[id=new_document_name]').val())

  $('.add-new-document-tool-link').live "click", ->
    $(this).closest('.root-tool').find('.add-new-document-tool').removeClass 'hidden'
    $(this).closest('.root-tool').find('.tool-add-links').addClass 'hidden'
    return false

  $('.cancel-add-document-tool').live "click", ->
    $(this).closest('.root-tool').find('input[id=new_document_name]').val('').trigger('focusout')
    $(this).closest('.root-tool').find('.add-new-document-tool').addClass 'hidden'
    $(this).closest('.root-tool').find('.tool-add-links').removeClass 'hidden'
    return false

  $('.add-new-document-tool-button').live "click", ->
    $(this).closest('.root-tool').find('.add-new-document-tool').addClass 'hidden'
    $(this).closest('.root-tool').find('.tool-add-links').removeClass 'hidden'


  $('.add-new-part-tool-link').live "click", ->
    $(this).closest('.root-tool').find('.add-new-part-tool').removeClass 'hidden'
    $(this).closest('.root-tool').find('.tool-add-links').addClass 'hidden'
    return false

  $('.cancel-add-part-tool').live "click", ->
    $(this).closest('.root-tool').find('input[id=new_part_material_number]').val('').trigger('focusout')
    $(this).closest('.root-tool').find('.add-new-part-tool').addClass 'hidden'
    $(this).closest('.root-tool').find('.tool-add-links').removeClass 'hidden'
    return false

  $('.add-new-part-tool-button').live "click", ->
    $(this).closest('.root-tool').find('.add-new-part-tool').addClass 'hidden'
    $(this).closest('.root-tool').find('.tool-add-links').removeClass 'hidden'


  $('#track_accessories').live "click", ->
    $.ajax '/job_templates/' + $(this).attr('data-job-template'),
      data: {track_accessories: $(this).is(':checked')},
      type: 'put', dataType: 'script'