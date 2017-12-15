initialize_print_page = () ->
  $('#print-button a').click ->
    window.print()

  if window.matchMedia
    mediaQueryList = window.matchMedia('print')
    mediaQueryList.addListener (mql) ->
      if mql.matches
        beforePrint()
      else
        afterPrint()
      return

  afterPrint = ->
    window.opener.location.focus()
    window.close()


  beforePrint = ->
    $('#print-form-page').submit()


  window.onbeforeprint = beforePrint
  window.onafterprint = afterPrint

click_it = () ->
  $('#print-button a').trigger('click')
  #window.close()
  preventDefault

$(document).on('page:load ready', initialize_print_page)
$(document).on('page:load ready', click_it)