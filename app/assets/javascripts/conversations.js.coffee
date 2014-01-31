

jQuery ->
  $('#message_recipients_tokens').tokenInput '/users.json'
    theme: 'facebook'
    hintText: "Type a person's name..."
    prePopulate: $('#message_recipients_tokens').data('pre'),
    #"<li><a><div class='job-user'><strong>" + item.value + " </strong><div><p class='job-user-title'>" + item.position_title + "</p><p class='job-user-district'>" + item.district + "</p></div></div></a></li>"

  $('.conversation-link').click ->
    $('.conversation-link').each ->
      if $(this).find('div:first').hasClass 'message-selected'
        $(this).find('div:first').removeClass 'message-selected'
        $(this).find('.new-message-dot').remove()
    $(this).find('div:first').addClass 'message-selected'
    $('#message_content').addClass 'hidden'
    $('#message_loading').removeClass 'hidden'
    $.ajax '/conversations/' + $(this).attr("id").replace("conversation_", ""), type: 'get', dataType: 'script'


  $('#conversation_messages_list').scrollTop($('#conversation_messages_list').height() + 10000)
  $('body').scrollTop(0)



  $('.conversation-link:first div:first').addClass 'message-selected'


