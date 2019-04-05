# frozen_string_literal: true

source 'https://rubygems.org'
# git_source(:github) do |repo_name|
#   repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
#   "https://github.com/#{repo_name}.git"
# end

# Health Checks!
gem 'okcomputer'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.6.1'
# Use mysql as the database for Active Record
gem 'mysql2', '>= 0.3.18', '< 0.4.11'
# Use Puma as the app server
gem 'puma', '~> 3.7'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'webpacker'

gem 'therubyracer', platforms: :ruby

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
gem 'redis'

# Resque Pool
gem 'resque-pool'

# SideKiq for queueing jobs
gem 'sidekiq'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Used to schedule cron jobs on the servers
gem 'whenever'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'

# Use Uglifier as compressor for JavaScript assets
# gem 'uglifier', '>= 2.7.2'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

gem 'jquery-rails'

# jQuery user interface widgets
gem 'jquery-ui-rails'
gem 'oj'
gem 'rabl'
gem 'rabl-rails'

# gem 'bootstrap-sass'

# FontAwesome sass integration
gem 'font-awesome-rails'

gem 'devise'

gem 'sprockets', '~> 3.7.2'

if ENV['CI']
  gem 'etda_utilities', branch: 'master', git: "https://#{ENV['ETDA_UTILITIES_TOKEN']}@github.com/psu-stewardship/etda_utilities.git"
else
  gem 'etda_utilities', branch: 'master', git: "git@github.com:psu-stewardship/etda_utilities.git"
end

gem 'rake', '< 11.0'

gem 'net-ldap', '~> 0.16.1'

gem 'country_select', git: 'https://github.com/stefanpenner/country_select.git', branch: 'master'

gem 'seedbank'

gem 'enumerize'

# Virus scanning for file uploads
gem 'clam_scan'

gem 'simple_form'

gem 'rest-client'

gem 'prawn'
gem 'caracal'  # for creating docx documents

# # Form builder
gem 'simple_form'

# File uploads
gem 'carrierwave'

# Virus scanning for file uploads
gem 'clam_scan'

# For image resizing
gem 'mini_magick'

# Easily handle nested forms
gem 'cocoon'

gem 'cancancan'

gem 'mail_form'

gem 'bundler-audit'

gem 'sinatra','~>  2.0.2'

gem 'rsolr'

# Call 'byebug' anywhere in the code to stop execution and get a debugger console
gem 'byebug', platforms: %i[mri mingw x64_mingw]

group :development, :test do

  gem 'rspec-rails'
  gem 'rubocop'
  gem 'rubocop-rspec'

  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 2.18'
  gem 'capybara-email'

  gem 'factory_bot_rails'
  gem 'faker'

  gem 'simplecov', require: false

  # manages solr 5 for development (using latest version from master as of 11/12/2015)
  gem 'solr_wrapper'

end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  gem "capistrano", "~> 3.10"
  gem 'capistrano-bundler', '~> 1.2', require: false
  gem 'capistrano-rails', '~> 1.2', require: false
  gem 'capistrano-rbenv', '~> 2.1', require: false
  gem 'capistrano-rbenv-install'
  gem 'capistrano-resque', '~> 0.2.1', require: false
  gem 'capistrano-passenger'

  # ------------
  # gem 'net-sftp', '2.1.2'
  # gem 'net-ssh-gateway', '1.2.0'
  # ------------

  gem 'better_errors'
  gem 'binding_of_caller'
end

group :test do
  gem 'rails-controller-testing'

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  # gem 'byebug', platforms: %i[mri mingw x64_mingw]

  gem 'launchy'
  gem 'poltergeist'

  gem "database_cleaner"

  gem 'shoulda-matchers', git: 'https://github.com/thoughtbot/shoulda-matchers.git', branch: 'rails-5'

  gem 'rspec-activemodel-mocks'

  gem 'webmock'
end
