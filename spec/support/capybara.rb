# frozen_string_literal: true

require 'capybara/rspec'
require 'capybara/dsl'
require 'capybara/rails'

RSpec.configure do |config|
  config.include(Capybara::DSL)
end

# Capybara.server = :puma # Until your setup is working
# Capybara.server = :puma, { Silent: true } # To clean up your test output
Capybara.server = :webrick # Using webrick so that ctl-c will stop rspec from running
