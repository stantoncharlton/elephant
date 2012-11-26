

jQuery ->
  $('#message_recipients_tokens').tokenInput '/users.json'
    theme: 'facebook'
    hintText: "Type a person's name..."
    #"<li><a><div class='job-user'><strong>" + item.value + " </strong><div><p class='job-user-title'>" + item.position_title + "</p><p class='job-user-district'>" + item.district + "</p></div></div></a></li>"

  $('.conversation-link').click ->
    $.ajax '/conversations/' + $(this).attr("id").replace("conversation_", ""), type: 'get', dataType: 'script'


  $('#conversation_messages_list').scrollTop($('#conversation_messages_list').height() + 10000)
  $('body').scrollTop(0)



  $('.conversation-link:first div:first').addClass 'message-selected'