

$ ->

  $('.div-expand-toggle').live "click", ->
    content = $(this).closest('.div-expand-root').find('.div-toggle-content:first')

    if content.css("display") == "none"
      content.css "display", "block"
    else
      content.css "display", "none"

    return false