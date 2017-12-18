initialize_alerts = () ->

  return unless $('.alert-dismissable').length

  $('.alert-dismissable').on('click', '.close', ->
    $('.alert').alert('close')
  )

$(document).on('page:load ready', initialize_alerts)