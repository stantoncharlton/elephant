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

  PartMemberships.init_show_all_part()
