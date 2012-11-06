$ ->


  # User Autocomplete -------------------
  $('#change_district_manager').click ->
    $('#district_manager_div').css('display', 'none')
    $('#district_manager_form').css('display', 'inline-block')
    $('#district_manager_name').focus()

  $('#district_manager_name').autocomplete
    source: $('#district_manager_name').data('autocomplete-source')
    select: (event, ui) ->
      $( "#district_manager_name" ).val( ui.item.label )
      $( "#district_manager_id" ).val( ui.item.id )
      $( "#district_manager_form" ).submit()

  $('#district_manager_name').data("autocomplete")._renderItem = (ul, item) ->
    return $("<li></li>").data("item.autocomplete", item).append(
      "<a><div class='job-user'><strong>" + item.value + " </strong><div><p class='job-user-title'>" + item.position_title + "</p><p class='job-user-district'>" + item.district + "</p></div></div></a>").appendTo(ul);


  $('#change_sales_engineer').click ->
    $('#sales_engineer_div').css('display', 'none')
    $('#sales_engineer_form').css('display', 'inline-block')
    $('#sales_engineer_name').focus()

  $('#sales_engineer_name').autocomplete
    source: $('#sales_engineer_name').data('autocomplete-source')
    select: (event, ui) ->
      $( "#sales_engineer_name" ).val( ui.item.label )
      $( "#sales_engineer_id" ).val( ui.item.id )
      $( "#sales_engineer_form" ).submit()

  $('#sales_engineer_name').data("autocomplete")._renderItem = (ul, item) ->
    return $("<li></li>").data("item.autocomplete", item).append(
      "<a><div class='job-user'><strong>" + item.value + " </strong><div><p class='job-user-title'>" + item.position_title + "</p><p class='job-user-district'>" + item.district + "</p></div></div></a>").appendTo(ul);




  $('.custom-data-input').change ->
    $.ajax '/dynamic_fields/' + $(this).attr("id").replace("dynamic_field_", "") + '?value=' + $(this).val(), type: 'put', dataType: 'script'

