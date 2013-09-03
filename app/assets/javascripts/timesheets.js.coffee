class Timesheet
  @recount: ->
    total_scheduled = 0
    total_worked = 0

    $('.timesheet').each (root_index, timesheet) =>
      user_worked = 0
      $(timesheet).find('.day-button').each (index, element) =>
        if $(element).attr('data-type') == 'worked'
          user_worked += parseInt($(element).val())
          total_scheduled += parseInt($(element).val())
        else if $(element).attr('data-type') == 'scheduled'
          total_scheduled += parseInt($(element).val())
        $(timesheet).find('.user-total-time').text(user_worked)
      total_worked += user_worked

    $('.total-scheduled').text(total_scheduled)
    $('.total-worked').text(total_worked)

$ ->

  $('.day-button-schedule').live "click", ->
    if $(this).attr("data-schedule-type") == "none"
      $(this).attr("data-schedule-type", "scheduled")
      $(this).removeClass "gray"
      $(this).addClass "light-blue"
      $(this).attr('data-type', 'scheduled')
      Timesheet.recount()
    else if $(this).attr("data-schedule-type") == "scheduled"
      $(this).attr("data-schedule-type", "confirmed")
      $(this).removeClass "light-blue"
      $(this).addClass "green"
      $(this).popover('show')
    else
      $(this).attr("data-schedule-type", "none")
      $(this).removeClass "green"
      $(this).addClass "gray"
      $(this).attr('data-type', 'none')

    return false


  $('.time-close-button').live "click", ->
    $('.day-button').popover('hide')
    return false

  $('.time-decrease-button').live "click", ->
    $('.time-confirm-button').val(parseInt($('.time-confirm-button').val()) - 1)
    return false

  $('.time-increase-button').live "click", ->
    $('.time-confirm-button').val(parseInt($('.time-confirm-button').val()) + 1)
    return false

  $('.time-confirm-button').live "click", ->
    popup = $(this).closest('.timesheet')
    main_button = $('.day-button[data-user=' + popup.attr('data-user') + '][data-day=' + popup.attr('data-day') + ']')
    main_button.val($(this).val())
    main_button.attr('data-type', 'worked')

    Timesheet.recount()

    $('.day-button').popover('hide')
    return false
