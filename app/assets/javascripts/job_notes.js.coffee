
$ ->

  $('#new_note_id').keydown ->
    $('#new_note_id').css('height', $('#new_note_id'))

  $('.note-comment').live 'focus', ->
    $(this).css('opacity', '1.0')




