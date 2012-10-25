$ ->

  $('#close_modal').live "click", ->
    $('#modal_popup').css "visibility", "hidden"
    $('#modal_popup').find(".modal-content").children().remove()
    $('#modal_popup').height(0)


  $('#new_field_link').click ->
    if $('#job_district_id').val() != ''
      $(this).attr 'href', "/fields/new" + '?district_id=' + $('#job_district_id').val()
    else
      alert('Select a District First')

  $('#new_well_link').click ->
    if $('#job_field_id').val() != ''
      $(this).attr 'href', "/wells/new" + '?field_id=' + $('#job_field_id').val()
    else
      alert('Select a Field First')

  if $('#job_district_id').val() == ''
    $('#job_field_id').attr "disabled", "disabled"
    $('#job_field_id').css "opacity", ".3"

  $('#job_well_id').attr "disabled", "disabled"
  $('#job_well_id').css "opacity", ".3"

  $('#job_job_template_id').attr "disabled", "disabled"
  $('#job_job_template_id').css "opacity", ".3"

  $('#job_district_id').change ->
    if $('#job_district_id').val() != ''
      $('#job_field_id').removeAttr("disabled")
      $('#job_field_id').css "opacity", "1"
      $.ajax '/fields?district_id=' + $('#job_district_id').val(), dataType: 'script'

  $('#job_field_id').change ->
    if $('#job_field_id').val() != ''
      $('#job_well_id').removeAttr("disabled")
      $('#job_well_id').css "opacity", "1"
      $.ajax '/wells?field_id=' + $('#job_field_id').val(), dataType: 'script'

  $('#job_product_line_id').change ->
    if $('#job_field_id').val() != ''
      $('#job_job_template_id').removeAttr("disabled")
      $('#job_job_template_id').css "opacity", "1"
      $.ajax '/product_lines?product_line_id=' + $('#job_product_line_id').val(), dataType: 'script'

  #enableSelectOnChange $('#job_district_id'), $('#job_field_id')
  #enableSelectOnChange $('#job_field_id'), $('#job_well_id')

  $.ajax '/fields?district_id=' + $('#job_district_id').val(), dataType: 'script'



enableSelectOnChange = (parent_select, child_select) ->
  parent_select.change ->
    if parent_select.val() != ''

      child_select.removeAttr("disabled")
      child_select.css "opacity", "1"

      #if isParentDistrict
      $.ajax '/fields?district_id=' + parent_select.val(), dataType: 'script'
      #else
      #  $.ajax '/wells?field_id=' + parent_select.val(), dataType: 'script'


