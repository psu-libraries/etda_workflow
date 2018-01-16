source 'https://rubygems.org'

# git_source(:github) do |repo_name|
#   repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
#   "https://github.com/#{repo_name}.git"
# end


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.1.4'
# Use mysql as the database for Active Record
gem 'mysql2', '>= 0.3.18', '< 0.4.10'
# Use Puma as the app server
gem 'puma', '~> 3.7'
# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'webpacker'

gem 'therubyracer', platforms: :ruby

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Used to schedule cron jobs on the servers
gem 'whenever'
# Use jquery as the JavaScript library
# gem 'jquery-rails'

# jQuery user interface widgets
# gem 'jquery-ui-rails'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'

# Use Uglifier as compressor for JavaScript assets
# gem 'uglifier', '>= 2.7.2'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem 'jquery-rails'

# jQuery user interface widgets
gem 'jquery-ui-rails'
gem 'rabl-rails'
gem 'rabl'
gem 'oj'

# gem 'bootstrap-sass'


# FontAwesome sass integration
# gem 'font-awesome-rails'

# Easily handle nested forms
gem 'cocoon'

gem 'devise'

if ENV['CI']
  gem 'etda_utilities', git: "https://#{ENV['ETDA_UTILITIES_TOKEN']}@github.com/psu-stewardship/etda_utilities.git"
else
  gem 'etda_utilities', git: 'git@github.com:psu-stewardship/etda_utilities.git'
end

gem 'rake', '< 11.0'

gem 'net-ldap', '~> 0.16.1'

gem 'country_select', git: 'https://github.com/stefanpenner/country_select.git', branch: 'master'

gem 'seedbank'

gem 'enumerize'

# Virus scanning for file uploads
gem 'clam_scan'

gem 'simple_form'
# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]

  gem "simplecov"

  gem 'rubocop', '0.35.1'
  gem 'rubocop-rspec', '1.3.1'
  gem 'rspec-rails'

  # Adds support for Capybara system testing and selenium driver
  gem 'capybara', '~> 2.13'
  gem 'capybara-email'

  gem 'factory_bot_rails'


end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  gem "capistrano", "~> 3.10"
  gem 'capistrano-bundler', '~> 1.2', require: false
  gem 'capistrano-rails', '~> 1.2', require: false
  gem 'capistrano-rbenv', '~> 2.1', require: false
  gem 'capistrano-rbenv-install'
  gem 'capistrano-resque', '~> 0.2.1', require: false


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
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]


  gem 'poltergeist'
  gem 'launchy'

  gem "database_cleaner"


  gem 'shoulda-matchers', git: 'https://github.com/thoughtbot/shoulda-matchers.git', branch: 'rails-5'

  gem 'rspec-activemodel-mocks'

  gem 'webmock'



end

