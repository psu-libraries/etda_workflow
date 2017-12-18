initialize_toggle_caret = () ->

  pointer = $('#reports_menu').find('span')
  $('#reports_list').on('shown.bs.collapse', ->
    pointer.removeClass('caret-right')).on('hidden.bs.collapse', -> pointer.addClass('caret-right'))

$(document).on('page:load ready', initialize_toggle_caret)