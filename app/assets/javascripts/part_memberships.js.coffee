class PartMemberships
  @init_show_all_part: ->
    $('.show-all-parts-material-number').on "click", ->
      box = $(this).closest('.filter-search-box').find('.part-match')
      if $(box.autocomplete('widget')).is(':visible')
        box.autocomplete('close')
      else
        box.autocomplete('search', $(this).attr('data-part-fill'))
      return false


$ ->

  $('.usage-hours').on "change", ->
    parent = $(this).closest('.parent-part-membership')
    $.ajax '/part_memberships/' + parent.attr("id").replace("part_membership_", "") + '?usage=' + $(this).val(), type: 'put', dataType: 'script'

  $('.update-usage-hours').on "click", ->
    return false


  PartMemberships.init_show_all_part()

  $('#show_shop_notes').on "click", ->
    $(this).addClass 'hidden'
    $('#shop_notes').removeClass 'hidden'
    $('#shop_notes').find('input').focus()
    return false

  $('.part-working').on "click", ->
    part = $('#part_membership_' + $(this).attr('data-id'))
    part.find('.popover').popover('hide')
    name = part.find('.name')
    name.text('working')
    name.addClass 'ajax-loading'
    name.addClass 'search-loading'
    name.next('div').text('')
    return false

