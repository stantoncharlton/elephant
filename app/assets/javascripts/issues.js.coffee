$ ->

  $(document).ready ->
    $('.issue-update-field').live "change", ->
      if $(this).prop('tagName').toLowerCase() == 'input' && $(this).attr('type').toLowerCase() == "checkbox"
        $.ajax '/issues/' + $(this).attr("data-id") + '?update_field=true&field=' + $(this).attr("data-field") + '&value=' + $(this).is(":checked"), type: 'put', dataType: 'script'
      else if $(this).val().length > 0
        $.ajax '/issues/' + $(this).attr("data-id") + '?update_field=true&field=' + $(this).attr("data-field") + '&value=' + $(this).val(), type: 'put', dataType: 'script'



