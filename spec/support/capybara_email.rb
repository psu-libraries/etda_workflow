# frozen_string_literal: true

require 'capybara/email/rspec'

RSpec.configure do |config|
  config.include(Capybara::Email::DSL)
end
