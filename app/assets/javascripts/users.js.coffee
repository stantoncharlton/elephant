
$ ->

  last_selected_item = null
  focusevent = (event, ui) ->
    if last_selected_item != null
      $('.item_' + last_selected_item.id).removeClass('ui-state-hover')
    selected_item = $('.item_' + ui.item.id)
    selected_item.addClass('ui-state-hover')
    last_selected_item = ui.item

  $('#district_name').autocomplete
    source: $('#district_name').data('autocomplete-source')
    focus: focusevent
    select: (event, ui) ->
      $("#district_name").val(ui.item.label)
      $("#district_id").val(ui.item.id).trigger("change")
