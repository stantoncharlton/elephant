class Parts
  @init: ->
    last_selected_item = null
    focusevent = (event, ui) ->
      if last_selected_item != null
        $('.item_' + last_selected_item.id).removeClass('ui-state-hover')
      selected_item = $('.item_' + ui.item.id)
      selected_item.addClass('ui-state-hover')
      last_selected_item = ui.item

    part_focused = false

    $('.part-match').each (index, element) =>
      $(element).autocomplete
        source: $(element).data('autocomplete-source')
        focus: focusevent
        select: (event, ui) ->
          $(this).closest('form').find('.part-id').val(ui.item.id)
          $(this).closest('form').submit()

    $('.part-match').live "focusin", ->
      part_focused = true
      $(this).removeClass 'ui-autocomplete-bad'
      $(this).addClass 'ui-autocomplete-typing'
      $(this).val('')


    $('.part-match').live "focusout", ->
      if part_focused
        $(this).addClass 'ui-autocomplete-bad'
        if $(this).val() == ''
          $(this).removeClass 'ui-autocomplete-typing'


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

  part_focused = false
  $('.part-search').focusin ->
    part_focused = true
    $(this).removeClass 'ui-autocomplete-bad'
    $(this).addClass 'ui-autocomplete-typing'
    $(this).val('')

  $('.part-search').focusout ->
    if part_focused
      $(this).addClass 'ui-autocomplete-bad'
      if $(this).val() == ''
        $(this).removeClass 'ui-autocomplete-typing'


  Parts.init()