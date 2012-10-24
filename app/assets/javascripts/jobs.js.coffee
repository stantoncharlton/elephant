$ ->

  $('#close_modal').live "click", ->
    $('#modal_popup').css "visibility", "hidden"
    $('#modal_popup').find(".modal-content").children().remove()
