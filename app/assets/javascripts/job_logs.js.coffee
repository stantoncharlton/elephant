$ ->

  $(".submit-enter").keypress (e) ->
    if e.which is 13
      $(this).blur()
      $(this).closest("form").find("input[type=submit]").trigger('click')
