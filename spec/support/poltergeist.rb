# frozen_string_literal: true

require 'capybara/poltergeist'

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, js_errors: false)
end
Capybara.javascript_driver = :poltergeist
# Capybara.threadsafe = true
Capybara.default_max_wait_time = 5
Capybara.automatic_reload = true
Capybara.raise_server_errors = false
# Returns Capybara 2 style string matching
# TODO this option will not be possible with Capybara 4
Capybara.default_normalize_ws = true
