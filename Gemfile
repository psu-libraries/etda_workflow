# frozen_string_literal: true

source 'https://rubygems.org'

ruby '2.6.0'

# Health Checks!
gem 'okcomputer'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.0'
# Use mysql as the database for Active Record
gem 'mysql2'
# Use Puma as the app server
gem 'puma', ">= 4.3.3"
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'webpacker', '~> 3.5.5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
gem 'redis'
# SideKiq for queueing jobs
gem 'sidekiq', '~> 5.2.8'
# When downgrading Sidekiq, rack needed to be downgraded as well.
# This can be removed for Sidekiq 6 or greater.
gem 'rack', '= 2.0.8'
# Used to schedule cron jobs on the servers
gem 'whenever'
# Use SCSS for stylesheets
gem 'sassc-rails'
# Jquery for rails
gem 'jquery-rails'
# jQuery user interface widgets
gem 'jquery-ui-rails'
# FontAwesome sass integration
gem 'font-awesome-rails'
# Authentication gem
gem "devise", ">= 4.7.1"
# Shared libraries for workflow and explore
gem 'etda_utilities', git: "https://github.com/psu-stewardship/etda_utilities.git", branch: 'master'
# Ldap client
gem 'net-ldap', '~> 0.16.1'
# Country drop-downs
gem 'country_select', git: 'https://github.com/stefanpenner/country_select.git', branch: 'master'
# Form builder
gem 'simple_form', '>= 5.0.0'
# File uploads
gem 'carrierwave', '~> 1.2.3'
# Virus scanning for file uploads
gem 'clam_scan'
# For image resizing
gem "mini_magick", ">= 4.9.4"
# Easily handle nested forms
gem 'cocoon'
# User authorization
gem 'cancancan'
# Easy email forms
gem 'mail_form'
# Audit gems
gem 'bundler-audit'
# Logging
gem 'logstash-event'
gem 'lograge'
gem 'lograge-sql'
# Ruby client for Apache solr
gem 'rsolr'
# Enumerated attributes with I18n
gem 'enumerize'
# Call 'byebug' anywhere in the code to stop execution and get a debugger console
gem 'byebug', platforms: %i[mri mingw x64_mingw]

group :development, :test do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Linter
  gem 'rubocop', '~> 0.61.1'
  gem 'rubocop-rspec', '~>  1.30.1'
  # Coverage report
  gem 'simplecov'
end

group :development do
  # Debugging with byebug/pry with web-console
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  # Deployment software
  gem "capistrano", "~> 3.10"
  gem 'capistrano-bundler', '~> 1.2'
  gem 'capistrano-rails', '~> 1.2'
  gem 'capistrano-rbenv', '~> 2.1'
  gem 'capistrano-rbenv-install'
  gem 'capistrano-passenger'
  # Support for newer ssh keys on newer machines
  gem 'ed25519'
  gem 'bcrypt_pbkdf'
  # ------------
  # gem 'net-sftp', '2.1.2'
  # gem 'net-ssh-gateway', '1.2.0'
  # ------------
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 2.18'
  gem 'capybara-email'
  # Fakes and factories for testing
  gem 'factory_bot_rails', '~> 5.0'
  gem 'faker'
  # Rspec for rails
  gem 'rspec-rails'
  # Use older controller testing methods
  gem 'rails-controller-testing'
  # Open webpage in browser
  gem 'launchy'
  # Web driver
  gem 'poltergeist'
  # Database cleaning
  gem "database_cleaner"
  # Extra matchers for rspec
  gem 'shoulda-matchers'
  # Retry on failure for finicky spec
  gem 'rspec-retry'
  # Stub http requests
  gem 'webmock'
end

group :production do
  # Datadog APM
  gem 'ddtrace', '~> 0.33'
end
