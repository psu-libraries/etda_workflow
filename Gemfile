# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.1.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.1'
# Use mysql as the database for Active Record
gem 'mysql2'
# Use Puma as the app server
gem 'puma', ">= 4.3.0"
# For bundling/importing assets
gem 'shakapacker', '~> 7.0.2'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# SideKiq for queueing jobs
gem 'sidekiq', '~> 7.1.3'
# Use SCSS for stylesheets
gem 'sassc-rails', '~> 2.1.0'
# Jquery for rails
gem 'jquery-rails', '~> 4.4.0'
# FontAwesome sass integration
gem 'font-awesome-rails', '~> 4.7.0.0'
# Authentication gem
gem "devise", ">= 4.7.1"
# Shared libraries for workflow and explore
gem 'etda_utilities', '~> 0.0'
# Ldap client
gem 'net-ldap', '~> 0.16.1'
# sftp for lionapth csv imports
gem "net-sftp", "~> 3.0"
# Country drop-downs
gem 'country_select', git: 'https://github.com/stefanpenner/country_select.git', branch: 'master'
# Form builder
gem 'simple_form', '>= 5.0.0'
# File uploads
gem 'carrierwave', '~> 2.2.5'
# Virus scanning for file uploads
gem 'clamby'
# For image resizing
gem "mini_magick", ">= 4.9.4"
gem "oauth2"
# Easily handle nested forms
gem 'cocoon', '~> 1.2.0'
# User authorization
gem 'cancancan', '~> 3.1.0'
# Easy email forms
gem 'mail_form', '~> 1.9.0'
# Logging & Health Checks!
gem 'okcomputer', '~> 1.18.0'
gem 'logstash-event', '~> 1.2.0'
gem 'lograge', '~> 0.11.0'
gem 'lograge-sql', '~> 1.1.0'
# Ruby client for Apache solr
gem 'rsolr', '~> 2.5.0'
# Enumerated attributes with I18n
gem 'enumerize', '~> 2.6.0'
# Call 'byebug' anywhere in the code to stop execution and get a debugger console
gem 'byebug', '~> 11.1.0', platforms: %i[mri mingw x64_mingw]
# HTTParty for http requests
gem 'httparty', '~> 0.21'
# For db seeding
gem 'seedbank', '~> 0.5.0'
# Loading assets
gem 'sprockets', '~> 3.7.2'
# Create pdf documents
gem 'prawn', '~> 2.4.0'
# Create docx documents
gem 'caracal', '~> 1.4.0'
gem 'net-imap', require: false          # For Ruby 3 and Rails 6 mail compatibility
gem 'net-pop', require: false           # For Ruby 3 and Rails 6 mail compatibility
gem 'net-smtp', require: false          # For Ruby 3 and Rails 6 mail compatibility
# Until the incompatibility issue with ruby 3 is fixed, limit psych to < 4
gem 'psych', '< 4'
# Matrix methods are needed for deployment
gem 'matrix', '~> 0.4.2'
# Support for newer ssh keys on newer machines
gem 'ed25519', '~> 1.2.4'
gem 'bcrypt_pbkdf', '~> 1.0.0'
# Error tracking
gem 'bugsnag', '~> 6.26'

group :development, :test do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'listen', '~> 3.7.0'
  # Linter
  gem 'rubocop', '~> 1.41.0'
  gem 'rubocop-rspec', '~>  2.19.0'
  gem 'rubocop-rails', '~>  2.18.0'
  # Coverage report
  gem 'simplecov', '~> 0.17.0'
end

group :development do
  # Debugging with byebug/pry with web-console
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring', '~> 2.1.0'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 3.38'
  gem 'capybara-email'
  gem 'webrick'
  # Fakes and factories for testing
  gem 'factory_bot_rails', '~> 5.0'
  gem 'faker', '~> 2.11.0'
  # Rspec for rails
  gem 'rspec-rails', '~> 4.0.0'
  # Use older controller testing methods
  gem 'rails-controller-testing', '~> 1.0.0'
  # Open webpage in browser
  gem 'launchy', '~> 2.5.0'
  # Web driver
  # Pinned at same version as the selenium container in docker-compose.yml
  gem 'selenium-webdriver', '~> 4.14'
  # Database cleaning
  gem "database_cleaner", '~> 1.8.0'
  # Extra matchers for rspec
  gem 'shoulda-matchers', '~> 4.3.0'
  # Retry on failure for finicky spec
  gem 'rspec-retry', '~> 0.6.0'
  # Stub http requests
  gem 'webmock', '~> 3.14.0'
end