# frozen_string_literal: true

Rails.application.configure do

  # Allow webconsole in docker containers
  config.web_console.allowed_ips = ['10.0.0.0/8', '172.20.0.0/12', '192.168.0.0/16']

  # Log rails output to stdout
  config.logger = ActiveSupport::TaggedLogging.new(ActiveSupport::Logger.new(STDOUT))

 # Verifies that versions and hashed value of the package contents in the project's package.json
  config.webpacker.check_yarn_integrity = true
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true
  #
  # preview emails
  config.action_mailer.show_previews = true

  # Enable/disable caching. By default caching is disabled.
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.seconds.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # #Email should not be active on any development servers
  # #During certain transactions (approval, release, etc.), emails are sent to the student
  # #and at times, committee members and the libraries.
  # #This is why email must not be sent from development servers.

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default_options = { from: "no-reply@psu.edu" }

  # turn email on using value of :email_indicator in secrets file (:test or :smtp).
  config.action_mailer.delivery_method = Rails.application.secrets[:email_indicator] || :test

  # Change default location for mailer previews
  config.action_mailer.preview_path = "#{Rails.root}/spec/mailers/previews"
  config.action_mailer.perform_caching = false

  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true
  config.assets.compile = false
  # Suppress logger output for asset requests.
  config.assets.quiet = true
  config.webpacker.check_yarn_integrity = false
  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  # config.file_watcher = ActiveSupport:: EventedFileUpdateChecker // this code doesn't work with M1 chip MacBooks
  config.file_watcher = ActiveSupport::FileUpdateChecker
end
