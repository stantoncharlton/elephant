$ ->

  $('#new_rig_link').live "click", ->
    $('#modal_popup').find(".modal-content").children().remove()
    return false