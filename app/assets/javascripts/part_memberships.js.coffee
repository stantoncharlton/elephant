class PartMemberships
  @init_show_all_part: ->
    $('.show-all-parts-material-number').live "click", ->
      box = $(this).closest('.filter-search-box').find('.part-match')
      if $(box.autocomplete('widget')).is(':visible')
        box.autocomplete('close')
      else
        box.autocomplete('search', $(this).attr('data-part-fill'))
      return false


$ ->

  $('.usage-hours').live "change", ->
    parent = $(this).closest('.parent-part-membership')
    $.ajax '/part_memberships/' + parent.attr("id").replace("part_membership_", "") + '?usage=' + $(this).val(), type: 'put', dataType: 'script'

  $('.update-usage-hours').live "click", ->
    return false


  PartMemberships.init_show_all_part()

  $('#show_shop_notes').live "click", ->
    $(this).addClass 'hidden'
    $('#shop_notes').removeClass 'hidden'
    $('#shop_notes').find('input').focus()
    return false

