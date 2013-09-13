$ ->

  $('.add-member-loading-button').click ->
    $('.member-loading').removeClass 'hidden'
    $('#new_member_form').hide()

  $('#add_job_member').live "click", ->
    $('#new_member_name').val('')
    $('#new_member_id').val('')
    $('#add_job_member').hide()
    $('#new_member_form').show()
    $('#new_member_name').focus()
    return false

  $('#cancel_add_member').live "click", ->
    $('#new_member_form').addClass 'hidden'
    $('#add_job_member').show()
    $('#new_member_form').hide()
    return false

  $('#toggle_member_names').live "click", ->
    if $(this).attr('data-toggle') == "open"
      $(this).attr('data-toggle', 'closed')
      $('.member-full-list').addClass 'hidden'
      $('#toggle_member_show').removeClass 'hidden'
      $('#toggle_member_hide').addClass 'hidden'
    else
      $(this).attr('data-toggle', 'open')
      $('.member-full-list').removeClass 'hidden'
      $('#toggle_member_show').addClass 'hidden'
      $('#toggle_member_hide').removeClass 'hidden'
    return false