$ ->

  $('.star-button').on "mouseenter", ->
    level = $(this).attr('level')
    $('.star-button').each ->
      if $(this).attr('level') <= level
        $(this).addClass 'star-button-hover'
      else
        $(this).removeClass 'star-button-hover'

  $('.star-button').on "mouseleave", ->
    $('.star-button').each ->
      $(this).removeClass 'star-button-hover'

  $('.star-button').on "click", ->
    level = $(this).attr('level')
    #$('.star-button-level').text(level)
    $('#value').val(level)
    $('.star-button').each ->
      if $(this).attr('level') <= level
        $(this).addClass 'star-button-filled'
      else
        $(this).removeClass 'star-button-filled'
    return false

  #$('.failure-checkbox').on "click", ->
  #  if $(this).is(':checked')
  #    $(this).closest('.field').find('.failure-reference').removeClass 'hidden'
  #  else
  #    $(this).closest('.field').find('.failure-reference').addClass 'hidden'
