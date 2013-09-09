$ ->

  $('.new-bha').live "click", ->
    $('.bha-content').addClass 'hidden'
    $('#bha_loader').removeClass 'hidden'
    $('.bha-button').each (index, element) ->
      $(element).addClass 'gray'
    return false

  $('.cancel-bha').live "click", ->
    $('.bha-button').first().trigger('click')
    $('body').animate({scrollTop : 0 }, 'fast')
    return false

  $('.bha-button').live "click", ->
    $('.bha-button').each (index, element) ->
      $(element).addClass 'gray'
    $(this).removeClass 'gray'
    $('body').animate({scrollTop : $('#bha').position().top - 70 }, 'fast')
    return false


  $('.bha-show-fields').live "click", ->
    parent = $(this).closest('.bha-tool')
    if $(this).is(':checked')
      parent.find('.bha-other-items').removeClass "hidden"
      #parent.find('.order-button').removeClass "hidden"
    else
      parent.find('.bha-other-items').addClass "hidden"
      #parent.find('.order-button').addClass "hidden"


  $('.bha-order-up').live "click", ->
    tool = $(this).closest('.bha-tool')
    prev = tool.prev()
    if prev.hasClass 'bha-tool'
      tool.remove()
      prev.before(tool)

      tool.addClass 'document-reorder-background'
      setTimeout (->
        tool.removeClass "document-reorder-background"
      ), 1000

    return false
