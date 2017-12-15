# This allows the footer to stick to the bottom of viewport
# if the page content is shorter then the viewport

#= require breakpoints.js

initialize_layout = () ->

  # Set breakpoints for responsive function calls
  $window = $(window)
  $window.setBreakpoints
    distinct: true,
    breakpoints: [ 768, 992, 1200 ]

  body_container = $('#body-container')
  $footer = body_container.find('footer')

  set_footer_margin = () ->
    footer_height = $footer.outerHeight(true)
    body_container.css('margin-bottom': footer_height)

  $window.bind('enterBreakpoint768 exitBreakpoint768', set_footer_margin)
  set_footer_margin()

$(document).on('page:load ready', initialize_layout)

