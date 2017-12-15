
setup_tooltips = () ->
  $('[data-toggle="tooltip"]').tooltip()

$(document).on('page:load ready', setup_tooltips)
