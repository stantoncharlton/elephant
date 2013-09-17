$ ->


  $('.secondary-tool').click ->
    $('.secondary-tool').closest('li').removeClass 'active'
    $(this).closest('li').addClass 'active'
    $('.loading').removeClass 'hidden'
    $.ajax '/secondary_tools?division=' + $(this).attr('id').replace('division_', ''), dataType: 'script'
    return false


  $('.secondary-tool-serial').live "change", ->
    $.ajax '/secondary_tools/' + $(this).attr("data-tool-id") + '?serial=' + $(this).val(), type: 'put', dataType: 'script'



  $('.duplicate-tool').live "click", ->
    $(this).find('.duplicate-message').addClass 'hidden'
    $(this).find('.duplicate-loading').removeClass 'hidden'
    return false