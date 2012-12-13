

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

    return false