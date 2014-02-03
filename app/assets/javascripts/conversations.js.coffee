

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



  $('#messages_icon_div').live "mouseover", ->
    $('#messages_window').removeClass('hidden')
    $('#messages_window').css('z-index', 1000000000)
    $('#messages_window').css('left', $(this).position().left - 80)
    $('#messages_window').css('top', $(this).position().bottom + 10)
    if !$('#messages_content').children().length > 0 && !$('#messages_content').hasClass('loading-content')
      $('#messages_content').addClass('loading-content')
      $.ajax '/conversations/', type: 'get', dataType: 'script'
    else
      $('#conversation_messages_list').scrollTop($('#conversation_messages_list').height() + 10000)
      $.ajax '/conversations/?open_only=true', type: 'get', dataType: 'script'

  $('#messages_icon_div').live "mouseout",  ->
    setTimeout ->
      if !$('#messages_window').is(':hover')
        $('html').css('overflow', 'auto')
        $('#messages_window').addClass('hidden')
      if $('#messages_icon_div').is(':hover')
        $('#messages_window').removeClass('hidden')
    , 100

  $('#messages_window').live "mouseover",  ->
    $('html').css('overflow', 'hidden')

  $('#messages_window').live "mouseout",  ->
    setTimeout ->
      if !$('#messages_window').is(':hover')
        $('html').css('overflow', 'auto')
        $('#messages_window').addClass('hidden')
      if $('#messages_icon_div').is(':hover')
        $('#messages_window').removeClass('hidden')
    , 100
