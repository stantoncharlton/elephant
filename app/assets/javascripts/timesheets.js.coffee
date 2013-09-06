class Timesheet
  @recount: ->
    total_scheduled = 0
    total_worked = 0

    $('.user-timesheet').each (root_index, timesheet) =>
      user_scheduled = parseInt($(timesheet).find('.user-total-time-scheduled').attr('data-hours'))
      user_worked = parseInt($(timesheet).find('.user-total-time').attr('data-hours'))
      total_scheduled += user_scheduled
      total_worked += user_worked

    $('.total-scheduled').text(total_scheduled)
    $('.total-worked').text(total_worked)

$ ->

  $('.day-button-schedule').live "click", ->
    job = $(this).attr('data-job')
    user = $(this).attr('data-user')
    date = $(this).attr('data-day')
    if $(this).attr("data-type") == "none"
      $(this).attr("data-type", "scheduled")
      $(this).removeClass "gray"
      $(this).addClass "light-blue"
      $(this).attr('data-type', 'scheduled')
      Timesheet.recount()
      $.ajax '/job_times/' + job,
        data: {schedule: true, user: user, date: date, hours: $(this).val()},
        type: 'put', dataType: 'script'
    else if $(this).attr("data-type") == "scheduled"
      $(this).attr("data-type", "worked")
      $(this).removeClass "light-blue"
      $(this).addClass "green"
      $(this).popover('show')
    else
      $(this).attr("data-type", "none")
      $(this).removeClass "green"
      $(this).addClass "gray"
      $(this).attr('data-type', 'none')
      Timesheet.recount()
      $.ajax '/job_times/' + job,
        data: {none: true, user: user, date: date},
        type: 'put', dataType: 'script'

    return false


  $('.time-close-button').live "click", ->
    popup = $(this).closest('.timesheet')
    main_button = $('.day-button[data-user=' + popup.attr('data-user') + '][data-day=' + popup.attr('data-day') + ']')
    job = main_button.attr('data-job')
    user = main_button.attr('data-user')
    date = main_button.attr('data-day')

    Timesheet.recount()
    $('.day-button').popover('hide')

    $.ajax '/job_times/' + job,
      data: {worked: true, user: user, date: date, hours: main_button.val()},
      type: 'put', dataType: 'script'
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
    job = main_button.attr('data-job')
    user = main_button.attr('data-user')
    date = main_button.attr('data-day')
    main_button.val($(this).val())
    main_button.attr('data-type', 'worked')

    Timesheet.recount()

    $('.day-button').popover('hide')

    $.ajax '/job_times/' + job,
      data: {worked: true, user: user, date: date, hours: main_button.val()},
      type: 'put', dataType: 'script'
    return false


  Timesheet.recount()

