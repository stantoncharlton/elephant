$ ->

  $('.share-document-button').live "click", ->
    $('#modal_popup').css('visibility', 'visible')
    $('#modal_popup').height($(document).height() + 100)
    $('#modal_popup').find('.loading').removeClass 'hidden'
    return false

  $('.sharing-loading-on-click').live "click", ->
    $('.sharing-form').addClass('hidden')
    $('.sharing-loading').removeClass('hidden')
