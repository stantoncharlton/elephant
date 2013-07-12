
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

  $('.part-search').each (index, element) =>
    $(element).autocomplete
      source: $(element).data('autocomplete-source')
      focus: focusevent
      select: (event, ui) ->
        if ui.item.id > 0
          window.location = '/parts/' +  ui.item.id

  $('.part-search2').autocomplete
    source: $(this).data('autocomplete-source')
    focus: focusevent
    select: (event, ui) ->
      if ui.item.id > 0
        window.location = '/parts/' +  ui.item.id
        #$("#part_search").val(ui.item.label)
        #$("#part_id").val(ui.item.id).trigger("change")

  part_focused = false
  $('.part-search').focusin ->
    part_focused = true
    $(this).removeClass 'ui-autocomplete-bad'
    $(this).addClass 'ui-autocomplete-typing'
    $(this).val('')
    #$('#part_id').val('')

  $('.part-search').focusout ->
    if part_focused #&& $('#part_id').val() == ''
      $(this).addClass 'ui-autocomplete-bad'
      if $(this).val() == ''
        $(this).removeClass 'ui-autocomplete-typing'