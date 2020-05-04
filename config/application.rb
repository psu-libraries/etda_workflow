# frozen_string_literal: true

require_relative 'boot'

# require 'rails/all'
#
require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
# require "action_cable/engine"
# require "sprockets/railtie"
# require "rails/test_unit/railtie"
require 'action_cable'
require 'csv'

require_relative '../lib/log/formatter'
#
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module EtdaWorkflow
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.

    config.load_defaults "6.0" # enables zeitwerk mode in CRuby

    # Logging
    logging_config = Rails.application.config_for(:logging)
    config.lograge.enabled = logging_config[:lograge][:enabled]

    config.lograge.formatter = Lograge::Formatters::Logstash.new if logging_config[:format] == 'logstash'

    config.logger = if logging_config[:stdout]
                        ActiveSupport::Logger.new(STDOUT)
                    else
                        ActiveSupport::Logger.new(Rails.root.join('log', "#{Rails.env}.log"))
                    end

    config.log_formatter = if logging_config[:format] == 'logstash'
                                JSONFormatter.new
                           else
                              ActiveSupport::Logger::SimpleFormatter.new
                           end

    config.logger.formatter = config.log_formatter

    # moved lib/devise to app/lib/devise to bypass eagerload/autoload issue rails 5
    # config.eager_load_paths << "#{Rails.root}/lib/**/*"
    #
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    #
    config.time_zone = 'Eastern Time (US & Canada)'
    config.active_record.default_timezone = :local
    config.active_record.time_zone_aware_attributes = false

    config.autoload_paths += Dir[Rails.root.join('app/presenters')]
    config.autoload_paths += Dir["#{config.root}/lib"]
    config.autoload_paths += Dir[File.join(Rails.root, "lib", "core_ext", "*.rb")].each {|l| require l }

    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', 'partners', I18n.default_locale.to_s, '*', '*.*{rb,yml}').to_s]

    config.assets.enabled = false
    config.generators do |g|
      g.assets false
    end
  end
end
