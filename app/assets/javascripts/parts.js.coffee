
$ ->

  $('#part_material_number').keyup (e) ->
    return if e.which is 16 || e.which is 9
    $('.part-loading').find('.loading').removeClass 'hidden'
    $('.part-loading').removeClass 'hidden'
    $.ajax '/parts/-1?material_number=' + $(this).val(), type: 'get', dataType: 'script'


  last_selected_item = null
  focusevent = (event, ui) ->
    if last_selected_item != null
      $('.item_' + last_selected_item.id).removeClass('ui-state-hover')
    selected_item = $('.item_' + ui.item.id)
    selected_item.addClass('ui-state-hover')
    last_selected_item = ui.item

  $('#part_search').autocomplete
    source: $('#part_search').data('autocomplete-source')
    focus: focusevent
    select: (event, ui) ->
      if ui.item.id > 0

        window.location = '/parts/' +  ui.item.id
        #$("#part_search").val(ui.item.label)
        #$("#part_id").val(ui.item.id).trigger("change")

  district_focused = false
  $('#part_search').focusin ->
    district_focused = true
    $('#part_search').removeClass 'ui-autocomplete-bad'
    $('#part_search').addClass 'ui-autocomplete-typing'
    $('#part_search').val('')
    $('#part_id').val('')

  $('#part_search').focusout ->
    if district_focused && $('#part_id').val() == ''
      $('#part_search').addClass 'ui-autocomplete-bad'
      if $('#part_search').val() == ''
        $('#part_search').removeClass 'ui-autocomplete-typing'