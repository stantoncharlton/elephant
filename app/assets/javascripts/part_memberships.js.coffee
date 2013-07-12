$ ->


  $('.show-all-parts-material-number').live "click", ->
    box = $(this).closest('.filter-search-box').find('.part-search')
    box.autocomplete('search', $(this).attr('data-part-fill'))
    return false