
$ ->

  $('#district_name').autocomplete
    source: $('#district_name').data('autocomplete-source')
    select: (event, ui) ->
      $("#district_name").val(ui.item.label)
      $("#district_id").val(ui.item.id).trigger("change")
