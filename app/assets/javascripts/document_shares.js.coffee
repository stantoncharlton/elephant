$ ->

  $('.share-document-button').on "click", ->
    $('#modal_popup').css('visibility', 'visible')
    $('#modal_popup').height($(document).height() + 100)
    $('#modal_popup').find('.modal-popup').css('margin-top', $('body').scrollTop() + 100)
    $('#modal_popup').find('.loading').removeClass 'hidden'
    return false

  $('.sharing-loading-on-click').on "click", ->
    $('.sharing-form').addClass('hidden')
    $('.sharing-loading').removeClass('hidden')


  $('.share-add-to-job').on "click", ->
    $('.form').addClass 'hidden'
    $('.loading').removeClass 'hidden'
    $('#document_share_job').val($(this).attr("id").replace("job_", ""))
    $(this).closest("form").submit()
    return false