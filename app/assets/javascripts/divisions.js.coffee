

$ ->

  $('.div-expand-toggle').live "click", ->
    content = $(this).closest('.div-expand-root').find('.div-toggle-content:first')
    header = $(this).closest('.div-expand-root').find('.header:first')

    if content.css("display") == "none"
      header.addClass "header-expanded"
      content.css "display", "block"
    else
      header.removeClass "header-expanded"
      content.css "display", "none"

    document.location.hash = "location_" + $(this).closest('.div-expand-root').attr 'id'

    return false

  if document.location.hash != '' && document.location.startsWith('#location_')
    root = $("#" + document.location.hash.replace('#location_', ''))
    root.find('.div-toggle-content:first').css "display", "block"
    root.find('.header:first').addClass "header-expanded"

    root.parents('.div-expand-root').each ->
      $(this).find('.div-toggle-content:first').css "display", "block"
      $(this).find('.header:first').addClass "header-expanded"
