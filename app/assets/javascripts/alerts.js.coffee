$ ->

  $('.start-loader').on "click", ->
    $('#calendar_loader').removeClass 'hidden'
    $('#calendar_navigation').addClass 'hidden'
    return true