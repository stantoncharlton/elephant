
$ ->

  last_selected_item = null
  focusevent = (event, ui) ->
    if last_selected_item != null
      $('.item_' + last_selected_item.id).removeClass('ui-state-hover')
    selected_item = $('.item_' + ui.item.id)
    selected_item.addClass('ui-state-hover')
    last_selected_item = ui.item

  $('#job_type_name').autocomplete
    source: $('#job_type_name').data('autocomplete-source')
    focus: focusevent
    select: (event, ui) ->
      window.location = "/job_templates/" + ui.item.id
      #$("#job_type_name").val(ui.item.label)
      #$("#job_type_name_id").val(ui.item.id)

      #$(this).closest("form").submit()

  $('.div-expand-toggle').live "click", ->
    content = $(this).closest('.div-expand-root').find('.div-toggle-content:first')
    header = $(this).closest('.div-expand-root').find('.header:first')

    if content.css("display") == "none"
      header.addClass "header-expanded"
      content.css "display", "block"
    else
      header.removeClass "header-expanded"
      content.css "display", "none"

    #document.location.hash = "location_" + $(this).closest('.div-expand-root').attr 'id'
    if window.history && window.history.pushState
      history.replaceState({}, "", '#' + "location_" + $(this).closest('.div-expand-root').attr 'id')

    return false


  if document.location.hash != ''
    if document.location.hash.match('#location_')
      root = $("#" + document.location.hash.replace('#location_', ''))
      root.find('.div-toggle-content:first').css "display", "block"
      root.find('.header:first').addClass "header-expanded"
      root.parents('.div-expand-root').each ->
        $(this).find('.div-toggle-content:first').css "display", "block"
        $(this).find('.header:first').addClass "header-expanded"

