$ ->

  last_selected_item = null
  focusevent = (event, ui) ->
    if last_selected_item != null
      $('.item_' + last_selected_item.id).removeClass('ui-state-hover')
    selected_item = $('.item_' + ui.item.id)
    selected_item.addClass('ui-state-hover')
    last_selected_item = ui.item

  $('#person_filter').autocomplete
    source: $('#person_filter').data('autocomplete-source')
    focus: focusevent
    select: (event, ui) ->
      $("#person_filter").val(ui.item.label)
      $("#person_filter_id").val(ui.item.id)
      $('.loading').removeClass 'hidden'
      $('#results').hide()
      $(this).closest("form").submit()

  $('#person_filter').change ->
    $("#person_filter_id").val('')

  $('#division_filter').autocomplete
    source: $('#division_filter').data('autocomplete-source')
    focus: focusevent
    select: (event, ui) ->
      $("#division_filter").val(ui.item.division_type + " " + ui.item.name)
      $("#division_filter_id").val(ui.item.division_type + "/////" + ui.item.id)
      $('.loading').removeClass 'hidden'
      $('#results').hide()
      $(this).closest("form").submit()

  $('#district_filter').autocomplete
    source: $('#district_filter').data('autocomplete-source')
    focus: focusevent
    select: (event, ui) ->
      $("#district_filter").val(ui.item.name)
      $("#district_filter_id").val(ui.item.id)
      $('.loading').removeClass 'hidden'
      $('#results').hide()
      $(this).closest("form").submit()

  $('.clear-filter-link').click ->
    $('#overview_filters').addClass 'hidden'
    $('.loading').removeClass 'hidden'
    $('#results').hide()

  $('#show_hide_overview_filters').click ->
    if $.trim($(this).text()) == "Show Detailed Filters"
      $(this).text("Hide Detailed Filters")
      $('#overview_filters').removeClass 'hidden'
      $('#all_filters_id').val('open')
    else
      $(this).text("Show Detailed Filters")
      $('#overview_filters').addClass 'hidden'
      $('#all_filters_id').val('')
    return false


  $('.overview-time-filter').click ->
    $('.overview-time-filter').each ->
      $(this).closest('li').removeClass 'active'
    $(this).closest('li').addClass 'active'
    $("#time_filter_id").val($(this).data('time'))
    $('.loading').removeClass 'hidden'
    $('#results').hide()
    $(this).closest("form").submit()

  $('.overview-rating-filter').click ->
    $('.overview-rating-filter').each ->
      $(this).closest('li').removeClass 'active'
    $(this).closest('li').addClass 'active'
    $("#rating_filter_id").val($(this).data('rating'))
    $('.loading').removeClass 'hidden'
    $('#results').hide()
    $(this).closest("form").submit()

  $('.overview-failure-filter').click ->
    $('.overview-failure-filter').each ->
      $(this).closest('li').removeClass 'active'
    $(this).closest('li').addClass 'active'
    $("#failure_filter_id").val($(this).data('failure'))
    $('.loading').removeClass 'hidden'
    $('#results').hide()
    $(this).closest("form").submit()
