$ ->

  $('#jump_to_district_select').change ->
    selected = $(this).find('option:selected')
    if selected.val() != ''
      window.location = "/inventory?district=" + $(this).find('option:selected').val()

  $('#district_id').change ->
    window.location = "/inventory?district=" + $(this).val()
