$ ->

  $('.star-button').live "mouseenter", ->
    level = $(this).attr('level')
    $('.star-button').each ->
      if $(this).attr('level') <= level
        $(this).addClass 'star-button-hover'
      else
        $(this).removeClass 'star-button-hover'

  $('.star-button').live "mouseleave", ->
    $('.star-button').each ->
      $(this).removeClass 'star-button-hover'

  $('.star-button').live "click", ->
    level = $(this).attr('level')
    #$('.star-button-level').text(level)
    $('#performance_rating').val(level)
    $('.star-button').each ->
      if $(this).attr('level') <= level
        $(this).addClass 'star-button-filled'
      else
        $(this).removeClass 'star-button-filled'
    return false

  #$('.failure-checkbox').live "click", ->
  #  if $(this).is(':checked')
  #    $(this).closest('.field').find('.failure-reference').removeClass 'hidden'
  #  else
  #    $(this).closest('.field').find('.failure-reference').addClass 'hidden'
