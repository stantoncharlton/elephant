$ ->

  $('.search-constraint-data-type').live "change", ->
    #$(this).closest('.field').find('.search-constraint-second').show()
    $.ajax '/search?data_type=' + $(this).val() + "&div_name=" + $(this).closest('.field').attr("id"), dataType: 'script'

  $('.search-constraint-product-line-select').live "change", ->
    #$(this).closest('.field').find('.search-constraint-second').show()
    $.ajax '/search?product_line=' + $(this).val() + "&div_name=" + $(this).closest('.field').attr("id"), dataType: 'script'

  $('.search-constraint-job-template-select').live "change", ->
    #$(this).closest('.field').find('.search-constraint-second').show()
    $.ajax '/search?job_template=' + $(this).val() + "&div_name=" + $(this).closest('.field').attr("id"), dataType: 'script'