$ ->


  $('.secondary-tool').click ->
    $('.secondary-tool').closest('li').removeClass 'active'
    $(this).closest('li').addClass 'active'
    $('.loading').removeClass 'hidden'
    $.ajax '/secondary_tools?division=' + $(this).attr('id').replace('division_', ''), dataType: 'script'
    return false


  $('.secondary-tool-serial').on "change", ->
    $.ajax '/secondary_tools/' + $(this).attr("data-tool-id") + '?serial=' + $(this).val(), type: 'put', dataType: 'script'

  $('.primary-tool-serial').on "change", ->
    $.ajax '/primary_tools/' + $(this).attr("data-tool-id") + '?serial=' + $(this).val(), type: 'put', dataType: 'script'

  $('.duplicate-tool').on "click", ->
    $(this).closest('.root-primary-tool').find('.duplicate-message').addClass 'hidden'
    $(this).closest('.root-primary-tool').find('.duplicate-loading').removeClass 'hidden'
    return false

  $('.change-tool').on "click", ->
    $(this).closest('.root-primary-tool').find('.duplicate-message').addClass 'hidden'
    $(this).closest('.root-primary-tool').find('.tool-changing-loading').removeClass 'hidden'
    return false


  $('.primary-tool-comments').on "change", ->
    $.ajax '/primary_tools/' + $(this).closest('.root-primary-tool').attr('id').replace('primary_tool_', ''),
      data: {comments: $(this).val() },
      type: 'put', dataType: 'script'
    return false

  $('.close-case-link').on "click", ->
    $(this).addClass 'hidden'
    $('.issue-closing-loading').removeClass 'hidden'
    $.ajax '/issues/' + $(this).attr('data-id'),
      data: {closed: true },
      type: 'put', dataType: 'script'
    return false


  $('.primary-tool-expand ').on "click", ->
    tool_details = $(this).closest('.root-primary-tool').find('.tool-details')
    if tool_details.hasClass 'hidden'
      tool_details.removeClass 'hidden'
      $(this).find('.primary-tool-expand-text').text('collapse')
    else
      tool_details.addClass 'hidden'
      $(this).find('.primary-tool-expand-text').text('expand')
    return false


  $('.primary-tool-select').on "change", ->
    tool_id = $(this).val()
    count = 0
    $('.root-primary-tool').each ->
      id = $(this).attr("data-tool-id")
      if tool_id == '0' || tool_id == id || tool_id == ''
        $(this).show()
        count = count + 1
      else
        $(this).hide()

    #$('#jobs_count_container').removeClass 'hidden'
    #$('#jobs_count').text(count)

  $('.primary-tools-expand ').on "click", ->
    tool_details = $(this).closest('.tools-root').next('.all-tool-details')
    if tool_details.hasClass 'hidden'
      $(this).addClass 'primary-tools-expanded'
      tool_details.removeClass 'hidden'
      $(this).find('.primary-tool-expand-text').text('collapse')
    else
      $(this).removeClass 'primary-tools-expanded'
      tool_details.addClass 'hidden'
      $(this).find('.primary-tool-expand-text').text('expand')
    return false

  $('.show-tool-notes').on "click", ->
    $(this).closest('.root-primary-tool').find('.tool-notes').removeClass 'hidden'
    $(this).addClass 'hidden'
    return false

  $('#add_new_tool').on "click", ->
    $('#add_new_tool_form').removeClass 'hidden'
    $(this).addClass 'hidden'
    return false

  $('#add_new_tool_submit').on "click", ->
    $.ajax '/primary_tools?id=' + $("#add_new_tool_select option:selected").val() + '&duplicate=true&from_master=true&job_id=' + $(this).attr("data-job-id"), type: 'post', dataType: 'script'
    return false