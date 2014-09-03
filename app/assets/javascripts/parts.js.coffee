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
          if ui.item.id > 0
            $(this).closest('form').find('.part-id').val(ui.item.id)
            $(this).closest('form').submit()

    $('.part-match').on "focusin", ->
      part_focused = true
      $(this).removeClass 'ui-autocomplete-bad'
      $(this).addClass 'ui-autocomplete-typing'
      $(this).val('')


    $('.part-match').on "focusout", ->
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
  $('.part-search').on "focusin", ->
    part_focused = true
    $(this).prev("input[id=part_membership_part_id]").val('')
    $(this).removeClass 'ui-autocomplete-bad'
    $(this).addClass 'ui-autocomplete-typing'
    $(this).val('')

  $('.part-search').on "focusout", ->
    if part_focused
      if $(this).prev("input[id=part_membership_part_id]").val() == ''
        $(this).addClass 'ui-autocomplete-bad'
      else
        $(this).removeClass 'ui-autocomplete-bad'
      if $(this).val() == ''
        $(this).removeClass 'ui-autocomplete-typing'


  Parts.init()


  $('#new_part_link').on "click", ->
    $('#part_serial_number').val('')
    $('#part_district_serial_number').val('')
    $(this).addClass 'hidden'
    $('#new_part_fields').removeClass 'hidden'
    $('#part_serial_number').focus()
    return false

  $('#cancel_part').on "click", ->
    $('#new_part_link').removeClass 'hidden'
    $('#new_part_fields').addClass 'hidden'
    return false

  $('#no_delete_asset').on "click", ->
    $('#modal_popup2').css('visibility', 'visible')
    $('#modal_popup2').height($(document).height() + 100)
    $('#modal_popup2').find('.modal-popup').css('margin-top', $('body').scrollTop() + 100)
    return false

  $('#rename_part_link').on "click", ->
    $('#part_name').val('')
    $('#rename_part_fields').removeClass 'hidden'
    $('#part_name').focus()
    return false

  $('#cancel_rename_part').on "click", ->
    $('#rename_part_fields').addClass 'hidden'
    return false

  $('#change_material_number_part_link').on "click", ->
    $('#part_material_number').val('')
    $('#material_number_part_fields').removeClass 'hidden'
    $('#part_material_number').focus()
    return false

  $('#cancel_material_number_part').on "click", ->
    $('#material_number_part_fields').addClass 'hidden'
    return false

  $('#change_serial_number_part_link').on "click", ->
    $('#part_serial_number').val('')
    $('#serial_number_part_fields').removeClass 'hidden'
    $('#part_serial_number').focus()
    return false

  $('#cancel_serial_number_part').on "click", ->
    $('#serial_number_part_fields').addClass 'hidden'
    return false


  $(document).ready ->
    $('.update-field').on "change", ->
      if $(this).val().length > 0
        $.ajax '/' + $(this).attr("data-controller") +  '/' + $(this).attr("data-id") + '?update_field=true&field=' + $(this).attr("data-field") + '&value=' + $(this).val(), type: 'put', dataType: 'script'


