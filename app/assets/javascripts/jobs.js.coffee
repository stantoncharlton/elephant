$ ->

  $('.custom-select').customSelect()

  if (!window.matchMedia || !window.matchMedia("(max-device-width: 1024px)").matches)
    $('.job-type-description-target').tooltip()
    $('.tooltip-info').tooltip()
    $('.unit-tooltip').tooltip()

  $('.unitsSelect').customSelect()

  $('.job-start-date').datepicker()
  $('.date-picker').datepicker()


  $('.job-start-date').change ->
    $.ajax '/jobs/' + $(this).attr("id").replace("job_start_date_", "") + '?start_date=' + $(this).val(), type: 'put', dataType: 'script'
    if $('#job_time_content').length() > 0
      $('#job_time_content').addClass 'hidden'
      $('#job_time_loader').removeClass 'hidden'

  $('#close_job a').live "click", ->
    $('#close_job').addClass 'hidden'
    if $('.current-job-status').length > 0
      $('.current-job-status').text('Complete')
    return false

  $('#begin_on_job a').live "click", ->
    $('#begin_on_job').addClass 'hidden'
    if $('.current-job-status').length > 0
      $('.current-job-status').text('On Job')
    return false

  $('#begin_post_job a').live "click", ->
    $('#begin_post_job').addClass 'hidden'
    if $('.current-job-status').length > 0
      $('.current-job-status').text('Post Job')
    return false

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
      if ui.item.id > 0
        $("#new_member_name").val(ui.item.label)
      $("#new_member_id").val(ui.item.id)
  #$("#new_member_form").submit()

  $('#new_note_name').autocomplete
    source: $('#new_note_name').data('autocomplete-source')
    focus: focusevent
    select: (event, ui) ->
      if ui.item.id > 0
        $("#new_note_name").val(ui.item.label)
        $("#new_note_name_id").val(ui.item.id)




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
    $.ajax '/dynamic_fields/' + $(this).attr("id").replace("dynamic_field_", "") + '?value=' + $(this).val() + "&job=" + $(this).attr('data-job') + "&name=" + $(this).attr('data-name'), type: 'put', dataType: 'script'

  $('.unitsSelect').change ->
    conversion = $(this).closest('.job-field-div').find('.job-field-conversion')
    if conversion
      conversion.remove()
    $.ajax '/dynamic_fields/' + $(this).attr("id").replace("dynamic_field_unit_", "") + '?unit=' + $(this).val(), type: 'put', dataType: 'script'


  $('.job-tray-toggle').click ->
    $('.job-tray-toggle').closest('li').removeClass 'active'
    $('.job-tray').addClass 'custom-data-closed'
    $(this).closest('li').addClass 'active'
    tray = $(this).attr('data-tray')
    $(".job-tray[data-tray=" + tray + "]").removeClass 'custom-data-closed'
    #document.location.hash = tray;
    if window.history && window.history.pushState
      history.replaceState({}, "", '#' + tray)

    if $('.job-main-div').length > 0
      $('body').animate({scrollTop : $('.job-main-div').position().top - 70 }, 'fast')
    event.preventDefault()

  $('.job-tray-toggle').click ->
    if $(this).attr('data-tray') == "activity"
      $('#activity_list').hide()
      $('.activity-loading').removeClass 'hidden'
      $('.activity-loading').find('.loading').removeClass 'hidden'
      if $('.job-main-div').length > 0
        $.ajax '/activities?job_id=' + $('.job-main-div').attr("id").replace("job_", ""), type: 'get', dataType: 'script'
    if $(this).attr('data-tray') == "job_failures"
      $('.failures_loading').removeClass 'hidden'
      $('.failures_loading').find('.loading').removeClass 'hidden'
      $.ajax '/jobs/' + $('.job-main-div').attr("id").replace("job_", "") + "?section=job_failures", type: 'get', dataType: 'script'
    if $(this).attr('data-tray') == "cost"
      $('.cost_loading').removeClass 'hidden'
      $('.cost_loading').find('.loading').removeClass 'hidden'
      $.ajax '/jobs/' + $('.job-main-div').attr("id").replace("job_", "") + "?section=cost", type: 'get', dataType: 'script'
    if $(this).attr('data-tray') == "reports"
      $('.reports_loading').removeClass 'hidden'
      $('.reports_loading').find('.loading').removeClass 'hidden'
      $.ajax '/jobs/' + $('.job-main-div').attr("id").replace("job_", "") + "?section=reports", type: 'get', dataType: 'script'
    if $(this).attr('data-tray') == "notes"
      $('.notes-loading').removeClass 'hidden'
      $('.notes-loading').find('.loading').removeClass 'hidden'
      $.ajax '/jobs/' + $('.job-main-div').attr("id").replace("job_", "") + "?section=notes", type: 'get', dataType: 'script'
    if $(this).attr('data-tray') == "time"
      $.ajax '/job_times/?job=' + $('.job-main-div').attr("id").replace("job_", ""), type: 'get', dataType: 'script'
    if $(this).attr('data-tray') == "documents_data"
      $('.documents_loading').removeClass 'hidden'
      $('.documents_loading').find('.loading').removeClass 'hidden'
      $.ajax '/jobs/' + $('.job-main-div').attr("id").replace("job_", "") + "?section=documents_data", type: 'get', dataType: 'script'
    if $(this).attr('data-tray') == "tools_assets"
      $('.assets_loading').removeClass 'hidden'
      $('.assets_loading').find('.loading').removeClass 'hidden'
      $.ajax '/jobs/' + $('.job-main-div').attr("id").replace("job_", "") + "?section=tools_assets", type: 'get', dataType: 'script'
    if $(this).attr('data-tray') == "failures"
      if $('#overview_failures').attr('data-loaded') != "true"
        $.ajax '/overview/' + "?section=failures", type: 'get', dataType: 'script'
    if $(this).attr('data-tray') == "insight"
      if $('#overview_insight').attr('data-loaded') != "true"
        $.ajax '/overview/' + "?section=insight", type: 'get', dataType: 'script'
    if $(this).attr('data-tray') == "company"
      if $('#overview_company').attr('data-loaded') != "true"
        $.ajax '/overview/' + "?section=company", type: 'get', dataType: 'script'
    if $(this).attr('data-tray') == "drilling"
      if $('#overview_drilling').attr('data-loaded') != "true"
        $.ajax '/overview/' + "?section=drilling", type: 'get', dataType: 'script'
    if $(this).attr('data-tray') == "jobs"
      if $('#overview_jobs').attr('data-loaded') != "true"
        $.ajax '/overview/' + "?section=jobs", type: 'get', dataType: 'script'
    if $(this).attr('data-tray') == "overview_npt"
      if $('#overview_npt').attr('data-loaded') != "true"
        $.ajax '/overview/' + "?section=overview_npt", type: 'get', dataType: 'script'
    if $(this).attr('data-tray') == "rigs"
      if $('#overview_rigs').attr('data-loaded') != "true"
        $.ajax '/overview/' + "?section=rigs", type: 'get', dataType: 'script'

    if $(this).attr('data-tray') == "asset_activity"
      $('#asset_activity_loading').removeClass 'hidden'
      $('#asset_activity_loading').find('.loading').removeClass 'hidden'
      $.ajax '/parts/' + $(this).attr('data-id') + "?section=asset_activity", type: 'get', dataType: 'script'
    event.preventDefault()

  $('.remote-tray-toggle').click ->
    $('.remote-tray-toggle').closest('li').removeClass 'active'
    $('.remote-tray').addClass 'custom-data-closed'
    $(this).closest('li').addClass 'active'

    tray_name = $(this).attr('data-tray')
    controller = $(this).attr('data-tray-controller')
    id = $(this).attr('data-id')
    if id == null
      id = 0

    if tray_name.length > 0 && controller.length > 0
      tray = $(".remote-tray[data-tray=" + tray_name + "]")
      tray.removeClass 'custom-data-closed'
      #document.location.hash = tray_name
      if window.history && window.history.pushState
        history.replaceState({}, "", '#' + tray_name)

      if tray.find('.tray-content').hasClass 'content-loaded'
        tray.find('.tray-content').show()
        tray.find('.remote-loading').addClass 'hidden'
        tray.find('.loading').addClass 'hidden'
      else
        tray.find('.tray-content').hide()
        tray.find('.remote-loading').removeClass 'hidden'
        tray.find('.loading').removeClass 'hidden'

        if id > 0
          $.ajax '/' + controller + '/' + id + "?section=" + tray_name, type: 'get', dataType: 'script'
        else
          $.ajax '/' + controller + "?section=" + tray_name, type: 'get', dataType: 'script'

    event.preventDefault()

  if document.location.hash != ''
    if $(".job-tray-toggle[data-tray=" + document.location.hash.replace('#', '') + "]").length != 0
      $(".job-tray-toggle[data-tray=" + document.location.hash.replace('#', '') + "]").trigger "click"
    else if $(".remote-tray-toggle[data-tray=" + document.location.hash.replace('#', '') + "]").length != 0
      $(".remote-tray-toggle[data-tray=" + document.location.hash.replace('#', '') + "]").trigger "click"


  #$('#add_failure').click ->
  #  $('#modal_popup').css('visibility', 'visible')
  #  $('#modal_popup').find('.modal-popup').css('margin-top', $('body').scrollTop() + 100)
  #  $('#modal_popup').height($(document).height() + 100)
  #  $('#modal_popup').find('.loading').removeClass 'hidden'


  $('.division-jobs-toggle').click ->
    $('.division-job-item').each ->
      if $(this).hasClass 'hidden'
        $(this).removeClass 'hidden'
      else
        $(this).addClass 'hidden'
    return false

#if $('#job_activities')
#  $.ajax '/activities' + '?job_id=' + $(this).val(), type: 'put', dataType: 'script'

  $('.expand-job-description').live "click", ->
    $(this).remove()
    $('.job-description-custom-data-div').css("max-height", 100000)
    return false



  $('.change-asset-type').live "click", ->
    $('.change-asset-type').each ->
      li = $(this).closest('li')
      if li.hasClass 'active'
        li.removeClass 'active'
        $(this).addClass 'blue-text'

    $(this).closest('li').addClass 'active'
    $(this).removeClass 'blue-text'

    $('.asset-type-form').each ->
      $(this).addClass 'hidden'

    $('.asset-type-form[data-type=' + $(this).attr('data-type') + ']').removeClass 'hidden'
    $('#part_type').val($(this).attr('data-type'))

    return false


  $('#complete_job').live "click", ->
    $.ajax '/jobs/' + $(this).attr('data-id') + "?section=rating", type: 'get', dataType: 'script'
    return true


  $('.job-update-field').live "change", ->
    if $(this).val().length > 0
      $.ajax '/jobs/' + $(this).attr("data-id") + '?update_field=true&field=' + $(this).attr("data-field") + '&value=' + $(this).val(), type: 'put', dataType: 'script'

  $('#confirm-assets').live "click", ->
    div = $(this).closest('div')
    div.addClass 'hidden'
    div.next('div').removeClass 'hidden'
    return false
  $('#confirm-assets-undo').live "click", ->
    div = $(this).closest('div')
    div.addClass 'hidden'
    div.prev('div').removeClass 'hidden'
    return false

  $('#jobs_filter').live "change", ->
    value = $(this).find('option:selected').val()
    $('.job-link').each ->
      $(this).show()
    if value == '1'
      $('.job-link').each ->
        if $(this).attr('data-member') == 'false'
          $(this).hide()
    if value == '2'
      $('.job-link').each ->
        if $(this).attr('data-status') != '5'
          $(this).hide()
    if value == '3'
      $('.job-link').each ->
        if $(this).attr('data-status') != '6'
          $(this).hide()
    if value == '4'
      $('.job-link').each ->
        if $(this).attr('data-status') != '7'
          $(this).hide()



  $('.loading-jobs').live 'click',  ->
    $('#jobs').addClass 'hidden'
    $('#jobs_loading').removeClass 'hidden'
    $('#jobs_loading').find('.loading').removeClass 'hidden'
    event.preventDefault()