$ ->

  $('.day-button-schedule').live "click", ->
    if $(this).attr("data-schedule-type") == "none"
      $(this).attr("data-schedule-type", "scheduled")
      $(this).removeClass "gray"
      $(this).addClass "light-blue"
    else if $(this).attr("data-schedule-type") == "scheduled"
      $(this).attr("data-schedule-type", "confirmed")
      $(this).removeClass "light-blue"
      $(this).addClass "green"
    else
      $(this).attr("data-schedule-type", "none")
      $(this).removeClass "green"
      $(this).addClass "gray"

    return false