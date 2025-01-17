ENV['RAILS_ENV'] ||= 'test'

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.root(File.expand_path('../..', __FILE__))
  SimpleCov.start('rails') do
    add_filter '/spec'
    add_filter '/tasks'
    add_filter '/channels'
    add_filter '/jobs'
    add_filter '/app/models/legacy'
    add_filter '/app/models/ldap_university_directory.rb'
  end
  SimpleCov.command_name 'spec'
end

require File.expand_path('../../config/environment', __FILE__)

# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'devise'
require 'cancan/ability'
require 'shoulda/matchers'
require 'rspec/retry'
require 'csv'
Dir[File.join(Rails.root, "lib", "core_ext", "*.rb")].each {|l| require l }

# WebMock: Allow localhost and selenium:4444 so we do not block communication between test instance and webdriver.
require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: true, allow: %r{selenium:4444})

# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!

# sidekiq
require 'sidekiq/testing'
Sidekiq::Testing.fake!  # by default it is fake

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migration and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!
DegreeType.seed
CommitteeRole.seed

RSpec.configure do |config|
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
  config.before(:each, js: true) do
    Capybara.default_max_wait_time = 5

    container_ip = Socket.ip_address_list.detect{|intf| intf.ipv4_private?}.ip_address
    Capybara.javascript_driver = :selenium
    Capybara.app_host = "http://#{container_ip}:3001"
    Capybara.server_port = "3001"
    Capybara.server_host = '0.0.0.0'

    args = ['--no-default-browser-check', '--start-maximized', '--kiosk-printing', '--headless']
    options = Selenium::WebDriver::Chrome::Options.new
    args.each do |arg|
      options.add_argument(arg)
    end
    Capybara.register_driver :selenium do |app|
      Capybara::Selenium::Driver.new(
          app,
          browser: :remote,
          url: "http://selenium:4444/wd/hub",
          options: options
      )
    end
  end

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_paths = ["#{::Rails.root}/spec/fixtures"]

  config.use_transactional_fixtures = false   # was true 8/27/18

  Shoulda::Matchers.configure do |cfg|
    cfg.integrate do |with|
      # Choose a test framework:
      with.test_framework :rspec
      with.library :rails
    end
  end

  config.include Devise::Test::ControllerHelpers, type: :controller
  #  config.include RequestSpecHelper, type: :request

  # show retry status in spec process
  config.verbose_retry = true
  # show exception that triggers a retry if verbose_retry is set to true
  config.display_try_failure_messages = true

  # callback to be run between retries
  config.retry_callback = proc do |ex|
    # run some additional clean up task - can be filtered by example metadata
    if ex.metadata[:js]
      Capybara.reset!
    end
  end

  # FactoryBot configuration
  config.include FactoryBot::Syntax::Methods

  # WebMock before integration tests
  config.before(:each, js: true) do
    stub_request(:get, /https:\/\/secure.gradsch.psu.edu\/services\/etd\/etdPayment.cfm/).
        to_return(status: 200, body: "\r\n    {\"data\":[{\"ETDPAYMENTFOUND\":\"Y\"}],\"error\":\"\"}\r\n    ")
  end
end
