$ ->

  last_selected_item = null
  focusevent = (event, ui) ->
    if last_selected_item != null
      $('.item_' + last_selected_item.id).removeClass('ui-state-hover')
    selected_item = $('.item_' + ui.item.id)
    selected_item.addClass('ui-state-hover')
    last_selected_item = ui.item

  $('#client_name').autocomplete
    source: $('#client_name').data('autocomplete-source')
    focus: focusevent
    select: (event, ui) ->
      $("#client_name").val(ui.item.label)
      $("#client_id").val(ui.item.id)


  $('#close_modal').live "click", ->
    $('#modal_popup').css "visibility", "hidden"
    $('#modal_popup').find(".modal-content").children().remove()
    $('#modal_popup').height(0)
    return false


  $('#new_field_link').click ->
    if $('#job_district_id').val() != ''
      $('body').animate({scrollTop : 0},'slow');
      $(this).attr 'href', "/fields/new" + '?district_id=' + $('#district_id').val()
    else
      alert('Select a District First')

  $('#new_well_link').click ->
    $('body').animate({scrollTop : 0},'slow');
    $(this).attr 'href', "/wells/new" + '?field_id=' + $('#job_field_id').val()

  if $('#job_district_id').val() == ''
    $('#job_field_id').attr "disabled", "disabled"
    $('#job_field_id').css "opacity", ".3"

  if $('#job_field_id').val() == ''
    $('#job_well_id').attr "disabled", "disabled"
    $('#job_well_id').css "opacity", ".3"

  if $('#job_segment_id').val() == ""
    $('#job_segment_id').attr "disabled", "disabled"
    $('#job_segment_id').css "opacity", ".3"

  if $('#job_product_line_id').val() == ""
    $('#job_product_line_id').attr "disabled", "disabled"
    $('#job_product_line_id').css "opacity", ".3"

  #if $('#job_job_template_id').val() == ""
  #  $('#job_job_template_id').attr "disabled", "disabled"
  #  $('#job_job_template_id').css "opacity", ".3"

  $('#job_division_id').change ->
    $('#job_segment_id').attr "disabled", "disabled"
    $('#job_segment_id').css "opacity", ".3"
    $('#job_product_line_id').attr "disabled", "disabled"
    $('#job_product_line_id').css "opacity", ".3"
    $('#job_job_template_id').attr "disabled", "disabled"
    $('#job_job_template_id').css "opacity", ".3"
    $('#job_segment_id').addClass "ajax-loading"
    if $('#job_division_id').val() != ''
      $.ajax '/divisions?division_id=' + $('#job_division_id').val(), dataType: 'script'

  $('#job_segment_id').change ->
    $('#job_product_line_id').attr "disabled", "disabled"
    $('#job_product_line_id').css "opacity", ".3"
    $('#job_job_template_id').attr "disabled", "disabled"
    $('#job_job_template_id').css "opacity", ".3"
    $('#job_product_line_id').addClass "ajax-loading"
    if $('#job_segment_id').val() != ''
      $.ajax '/segments?segment_id=' + $('#job_segment_id').val(), dataType: 'script'

  $('#job_product_line_id').change ->
    $('#job_job_template_id').attr "disabled", "disabled"
    $('#job_job_template_id').css "opacity", ".3"
    if $('#job_product_line_id').val() != ''
      $(this).closest('.content').find('.loading').removeClass "hidden"
      $.ajax '/product_lines?product_line_id=' + $('#job_product_line_id').val(), dataType: 'script'

  $('#job_job_template_id').change ->
    if $('#job_job_template_id').val() != ''
      $.ajax '/job_templates/' + $('#job_job_template_id').val(), dataType: 'script'

  $('#district_id').change ->
    if $('#district_id').val() != ''
      $('#job_field_id').removeAttr("disabled")
      $('#job_field_id').css "opacity", "1"
      $.ajax '/fields?district_id=' + $('#district_id').val(), dataType: 'script'

  $('#job_field_id').change ->
    if $('#job_field_id').val() != ''
      $('#job_well_id').removeAttr("disabled")
      $('#job_well_id').css "opacity", "1"
      $('#job_well_id').attr "disabled", "disabled"
      $('#job_well_id').css "opacity", ".3"
      $('#job_well_id').addClass "ajax-loading"
      $.ajax '/wells?field_id=' + $('#job_field_id').val(), dataType: 'script'


  if $('#job_district_id').val()
    $.ajax '/fields?district_id=' + $('#job_district_id').val(), dataType: 'script'


  $('.job-type-selection').live "click", ->
    $('.job-type-selection').removeClass('job-type-selected')
    $(this).addClass('job-type-selected')
    $val = $(this).attr('id').replace('job_template_', '')
    $('#job_job_template_id').removeAttr "disabled", "disabled"
    $('#job_job_template_id').val($val)
    return false