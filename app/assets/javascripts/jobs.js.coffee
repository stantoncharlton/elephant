$ ->

  $('.job-type-description-target').tooltip()
  $('.unit-tooltip').tooltip()
  $('.unitsSelect').customSelect()

  $('#new_member_name').autocomplete
    source: $('#new_member_name').data('autocomplete-source')
    select: (event, ui) ->
      $("#new_member_name").val(ui.item.label)
      $("#new_member_id").val(ui.item.id)
      #$("#new_member_form").submit()

  $('#new_note_name').autocomplete
    source: $('#new_note_name').data('autocomplete-source')
    select: (event, ui) ->
      $("#new_note_name").val(ui.item.label)
      $("#new_note_name_id").val(ui.item.id)
      #$("#new_note_form").submit()


  $('.job-member-list-item').live "mouseenter", ->
    $(this).find('.delete-button-small').css('visibility', 'visible')

  $('.job-member-list-item').live "mouseleave", ->
    $(this).find('.delete-button-small').css('visibility', 'hidden')

  $('.custom-data-input').click ->
    $(this).select()

  $('.custom-data-input').change ->
    $.ajax '/dynamic_fields/' + $(this).attr("id").replace("dynamic_field_", "") + '?value=' + $(this).val(), type: 'put', dataType: 'script'

  $('.unitsSelect').change ->
    $.ajax '/dynamic_fields/' + $(this).attr("id").replace("dynamic_field_unit_", "") + '?unit=' + $(this).val(), type: 'put', dataType: 'script'


#if $('#job_activities')
#  $.ajax '/activities' + '?job_id=' + $(this).val(), type: 'put', dataType: 'script'



