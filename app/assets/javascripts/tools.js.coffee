$ ->


  $('.secondary-tool').click ->
    $('.secondary-tool').closest('li').removeClass 'active'
    $(this).closest('li').addClass 'active'
    $('.loading').removeClass 'hidden'
    $.ajax '/secondary_tools?division=' + $(this).attr('id').replace('division_', ''), dataType: 'script'
    return false


  $('.secondary-tool-serial').live "change", ->
    $.ajax '/secondary_tools/' + $(this).attr("data-tool-id") + '?serial=' + $(this).val(), type: 'put', dataType: 'script'

  $('.primary-tool-serial').live "change", ->
    $.ajax '/primary_tools/' + $(this).attr("data-tool-id") + '?serial=' + $(this).val(), type: 'put', dataType: 'script'

  $('.duplicate-tool').live "click", ->
    $(this).closest('.root-primary-tool').find('.duplicate-message').addClass 'hidden'
    $(this).closest('.root-primary-tool').find('.duplicate-loading').removeClass 'hidden'
    return false

  $('.change-tool').live "click", ->
    $(this).closest('.root-primary-tool').find('.duplicate-message').addClass 'hidden'
    $(this).closest('.root-primary-tool').find('.tool-changing-loading').removeClass 'hidden'
    return false


  $('.primary-tool-comments').live "change", ->
    $.ajax '/primary_tools/' + $(this).closest('.root-primary-tool').attr('id').replace('primary_tool_', ''),
      data: {comments: $(this).val() },
      type: 'put', dataType: 'script'
    return false

  $('.close-case-link').live "click", ->
    $(this).addClass 'hidden'
    $('.issue-closing-loading').removeClass 'hidden'
    $.ajax '/issues/' + $(this).attr('data-id'),
      data: {closed: true },
      type: 'put', dataType: 'script'
    return false