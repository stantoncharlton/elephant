
$ ->

  $("form").on "submit", ->
    if !$(this).attr('data-remote')
      $(this).find(":submit").attr('disabled', 'disabled');