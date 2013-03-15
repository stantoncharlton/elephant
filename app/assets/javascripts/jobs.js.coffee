$ ->

  $('.custom-select').customSelect()

  if (!window.matchMedia || !window.matchMedia("(max-device-width: 1024px)").matches)
    $('.job-type-description-target').tooltip()
    $('.tooltip-info').tooltip()
    $('.unit-tooltip').tooltip()

  $('.unitsSelect').customSelect()

  $('.job-start-date').datepicker()

  $('.job-start-date').change ->
    $.ajax '/jobs/' + $(this).attr("id").replace("job_start_date_", "") + '?start_date=' + $(this).val(), type: 'put', dataType: 'script'

  last_selected_item = null
  focusevent = (event, ui) ->
    if last_selected_item != null
      $('.item_' + last_selected_item.id).removeClass('ui-state-hover')
    selected_item = $('.item_' + ui.item.id)
    selected_item.addClass('ui-state-hover')
    last_selected_item = ui.item

  $('#new_member_name').autocomplete
    source: $('#new_member_name').data('autocomplete-source')
    focus: focusevent
    select: (event, ui) ->
      $("#new_member_name").val(ui.item.label)
      $("#new_member_id").val(ui.item.id)
  #$("#new_member_form").submit()

  $('#new_note_name').autocomplete
    source: $('#new_note_name').data('autocomplete-source')
    focus: focusevent
    select: (event, ui) ->
      $("#new_note_name").val(ui.item.label)
      $("#new_note_name_id").val(ui.item.id)
  #$("#new_note_form").submit()

  $('#division_search_name').autocomplete
    source: $('#division_search_name').data('autocomplete-source')
    focus: focusevent
    select: (event, ui) ->
      $("#division_search_name").val(ui.item.division_type + " " + ui.item.name)
      $("#division_search_name_id").val(ui.item.division_type + "/////" + ui.item.id)


  $('.job-member-list-item').live "mouseenter", ->
    $(this).find('.job-member-edit-button').css('visibility', 'visible')
    $(this).find('.delete-button-small').css('visibility', 'visible')

  $('.job-member-list-item').live "mouseleave", ->
    $(this).find('.job-member-edit-button').css('visibility', 'hidden')
    $(this).find('.delete-button-small').css('visibility', 'hidden')

  $('.custom-data-input').click ->
    $(this).select()

  $('.custom-data-input').keyup ->
    conversion = $(this).closest('.job-field-div').find('.job-field-conversion')
    if conversion
      conversion.remove()

  $('.custom-data-input').change ->
    conversion = $(this).closest('.job-field-div').find('.job-field-conversion')
    if conversion
      conversion.remove()
    $.ajax '/dynamic_fields/' + $(this).attr("id").replace("dynamic_field_", "") + '?value=' + $(this).val(), type: 'put', dataType: 'script'

  $('.unitsSelect').change ->
    conversion = $(this).closest('.job-field-div').find('.job-field-conversion')
    if conversion
      conversion.remove()
    $.ajax '/dynamic_fields/' + $(this).attr("id").replace("dynamic_field_unit_", "") + '?unit=' + $(this).val(), type: 'put', dataType: 'script'


  $('.job-tray-toggle').click ->
    close = $(this).closest('li').hasClass 'active'
    $('.job-tray-toggle').closest('li').removeClass 'active'
    $('.job-tray').addClass 'custom-data-closed'
    if !close
      $(this).closest('li').addClass 'active'
      $(".job-tray[data-tray=" + $(this).attr('data-tray') + "]").removeClass 'custom-data-closed'
    return false


  $('#add_failure').click ->
    $('#modal_popup').css('visibility', 'visible')
    $('#modal_popup').height($(document).height() + 100)
    $('#modal_popup').find('.loading').removeClass 'hidden'



#if $('#job_activities')
#  $.ajax '/activities' + '?job_id=' + $(this).val(), type: 'put', dataType: 'script'



