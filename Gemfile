source 'https://rubygems.org'

# git_source(:github) do |repo_name|
#   repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
#   "https://github.com/#{repo_name}.git"
# end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.4'
# Use mysql as the database for Active Record
gem 'mysql2', '>= 0.3.18', '< 0.5'
# Use Puma as the app server
gem 'puma', '~> 3.7'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# See https://github.com/rails/execjs#readme for more supported runtimes

gem 'therubyracer', platforms: :ruby

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Used to schedule cron jobs on the servers
gem 'whenever'
# Use jquery as the JavaScript library
gem 'jquery-rails'

# jQuery user interface widgets
gem 'jquery-ui-rails'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'devise'

gem 'etda_utilities', git: "https://#{ENV.fetch('ETDA_UTILITIES_TOKEN')}@github.com/psu-stewardship/etda_utilities.git", branch: 'master'


# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]

  gem "simplecov"

  gem 'rubocop', '0.35.1'
  gem 'rubocop-rspec', '1.3.1'
  gem 'rspec-rails'

  gem 'rake', '< 11.0'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  gem 'capistrano-resque', '~> 0.2.1', require: false

  # Deploy to multiple environments
  gem 'capistrano-ext'

  # rbenv support for capistrano
  gem 'capistrano-rbenv', '1.0.5'

  gem 'capistrano-notification'

  # Fix for old capistrano, should be deleted when we upgrade cap
  # ------------
  gem 'net-sftp', '2.1.2'
  gem 'net-ssh-gateway', '1.2.0'
  # ------------

  gem 'better_errors'
  gem 'binding_of_caller'


end

group :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]

  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 2.13'

  gem 'selenium-webdriver'

  gem "database_cleaner"


  gem 'shoulda-matchers', git: 'https://github.com/thoughtbot/shoulda-matchers.git', branch: 'rails-5'

  gem 'rspec-activemodel-mocks'

  gem 'webmock'

  gem 'factory_girl_rails'

end

