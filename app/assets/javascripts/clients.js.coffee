$ ->

  $('#client_name_id').keyup ->
    $.ajax '/clients?search=' + $(this).val(), type: 'get', dataType: 'script'