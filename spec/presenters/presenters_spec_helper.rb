require 'presenters/presenter_spec_helper'
# require 'support/url_helpers'

class MyTemplate
  attr_accessor :output_buffer

  include ActionView::Helpers::TagHelper
  include Rails.application.class.routes.url_helpers
  include ActionView::Helpers::UrlHelper
end
