
$ ->

  $('#new_note_id').keydown ->
    $('#new_note_id').css('height', $('#new_note_id'))

  $('.note-comment').live 'focus', ->
    $(this).css('opacity', '1.0')



  $('.change-note-type').live "click", ->
    $('.change-note-type').each ->
      li = $(this).closest('li')
      if li.hasClass 'active'
        li.removeClass 'active'
        $(this).addClass 'blue-text'

    $(this).closest('li').addClass 'active'
    $(this).removeClass 'blue-text'
    $('#new_note_id').val('')
    $('#new_note_name').val('')

    $('#note_report').addClass 'hidden'
    switch $(this).attr('data-note')
      when 'note'
        $('#new_note_id').removeClass 'hidden'
        $('#assign_note_user').addClass 'hidden'
        $('#note_type_id').val('1')
      when 'task'
        $('#new_note_id').removeClass 'hidden'
        $('#assign_note_user').removeClass 'hidden'
        $('#note_type_id').val('4')
      when 'warning'
        $('#new_note_id').removeClass 'hidden'
        $('#assign_note_user').removeClass 'hidden'
        $('#note_type_id').val('2')
      when 'report'
        $('#new_note_id').addClass 'hidden'
        $('#assign_note_user').addClass 'hidden'
        $('#note_report').removeClass 'hidden'
        $('#note_type_id').val('5')
      when 'asset'
        $('#new_note_id').removeClass 'hidden'
        $('#assign_note_user').addClass 'hidden'
        $('#note_type_id').val('6')
    return false

  $('.change-note-type[data-note=report]').trigger('click')

  $('.activity-report-show-all').live "click", ->
    root = $(this).closest('.activity-report-root')
    $(this).addClass 'hidden'
    root.find('.past-day').removeClass 'hidden'
    root.find('.present-day').removeClass 'hidden'
    root.find('.next-day').removeClass 'hidden'
    return false

