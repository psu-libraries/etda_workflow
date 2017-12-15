initialize_nested_fields = () ->

  cocoon_link = $('.cocoon-links .add_fields')

  return unless cocoon_link.length

  fields = $('.nested-fields')

  unless fields.length
    cocoon_link.click()

$(document).on('page:load ready', initialize_nested_fields)