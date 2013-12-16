$ ->

  $('.issue-update-field').live "change", ->
    $.ajax '/issues/' + $(this).attr("data-id") + '?update_field=true&field=' + $(this).attr("data-field") + '&value=' + $(this).val(), type: 'put', dataType: 'script'

