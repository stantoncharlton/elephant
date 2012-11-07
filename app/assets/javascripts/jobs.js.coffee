$ ->

  $('#new_member_name').autocomplete
    source: $('#new_member_name').data('autocomplete-source')
    select: (event, ui) ->
      $( "#new_member_name" ).val( ui.item.label )
      $( "#new_member_id" ).val( ui.item.id )
      $( "#new_member_form" ).submit()

  $('#new_member_name').data("autocomplete")._renderItem = (ul, item) ->
    return $("<li></li>").data("item.autocomplete", item).append(
      "<a><div class='job-user'><strong>" + item.value + " </strong><div><p class='job-user-title'>" + item.position_title + "</p><p class='job-user-district'>" + item.district + "</p></div></div></a>").appendTo(ul)


  $('.job-member-list-item').live "mouseenter", ->
    $(this).find('.delete-button-small').css('visibility', 'visible')

  $('.job-member-list-item').live "mouseleave", ->
    $(this).find('.delete-button-small').css('visibility', 'hidden')

  $('.custom-data-input').change ->
    $.ajax '/dynamic_fields/' + $(this).attr("id").replace("dynamic_field_", "") + '?value=' + $(this).val(), type: 'put', dataType: 'script'

