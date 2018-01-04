ENV["RAILS_ENV"] ||= 'test'
puts "Loading Rails..."
require "#{ROOT}/config/environment"
require 'rspec/rails'
require 'shoulda/matchers'

RSpec.configure do |config|
  # Allow rspec to use named routes
  config.include Rails.application.routes.url_helpers
  # config.include RSpec::Rails::ViewRendering
end
