require 'capybara/rspec'
require 'capybara/dsl'

RSpec.configure do |config|
  config.include(Capybara::DSL)
end
