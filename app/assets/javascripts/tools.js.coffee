$ ->


  $('.secondary-tool').click ->
    $('.secondary-tool').closest('li').removeClass 'active'
    $(this).closest('li').addClass 'active'
    $('.loading').removeClass 'hidden'
    $.ajax '/secondary_tools?division=' + $(this).attr('id').replace('division_', ''), dataType: 'script'
    return false