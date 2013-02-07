$ ->

  last_selected_item = null
  focusevent = (event, ui) ->
    if last_selected_item != null
      $('.item_' + last_selected_item.id).removeClass('ui-state-hover')
    selected_item = $('.item_' + ui.item.id)
    selected_item.addClass('ui-state-hover')
    last_selected_item = ui.item

  $('.add-search-field').click ->
    $('.search-field').each (index, element) =>
      if $(element).css("display") == "none"
        $(element).show()
        return false
    return false

  $('.client-name').each (index, element) =>
    $(element).autocomplete
      source: $(element).data('autocomplete-source')
      focus: focusevent
      select: (event, ui) ->
        $(this).closest('.search-field').find("input[id=client_id]").val(ui.item.id)

  $('.district-name').each (index, element) =>
    $(element).autocomplete
      source: $(element).data('autocomplete-source')
      focus: focusevent
      select: (event, ui) ->
        $(this).closest('.search-field').find("input[id=district_id]").val(ui.item.id)


  $('.search-constraint-data-type').live "change", ->

    $(this).closest('.search-field').find('.search-constraint-second').hide();
    $(this).closest('.search-field').find('.search-job-type').hide();

    if $(this).val() == '3'
      $(this).closest('.search-field').find('.client-name').show()
    else
      $(this).closest('.search-field').find('.client-name').hide()

    if $(this).val() == '4'
      $(this).closest('.search-field').find('.district-name').show()
    else
      $(this).closest('.search-field').find('.district-name').hide()

    if $(this).val() == '2' || $(this).val() == '1'
      $.ajax '/search?data_type=' + $(this).val() + "&div_name=" + $(this).closest('.search-field').attr("id"), dataType: 'script'

  $('.search-constraint-product-line-select').live "change", ->
    $.ajax '/search?product_line=' + $(this).val() + "&div_name=" + $(this).closest('.search-field').attr("id"), dataType: 'script'

  $('.search-constraint-job-template-select').live "change", ->
    $.ajax '/search?job_template=' + $(this).val() + "&div_name=" + $(this).closest('.search-field').attr("id"), dataType: 'script'