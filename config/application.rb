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
#
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module EtdaWorkflow
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # moved lib/devise to app/lib/devise to bypass eagerload/autoload issue rails 5
    # config.eager_load_paths << "#{Rails.root}/lib/**/*"
    #
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    #
    config.time_zone = 'Eastern Time (US & Canada)'
    config.autoload_paths += [
      Rails.root.join('app/presenters'),
      Rails.root.join('app/decorators')
    ]
    config.autoload_paths += Dir["#{config.root}/lib/**/*"]

    # config.autoload_paths << Rails.root.join("lib")
    # config.eager_load_paths << Rails.root.join("lib")
    # config.eager_load_paths << Rails.root.join("app", "services", '*', '*.rb')
    config.autoload_paths += Dir[File.join(Rails.root, "lib", "core_ext", "*.rb")].each { |l| require l }

    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', 'partners', I18n.default_locale.to_s, '*', '*.*{rb,yml}').to_s]

    config.assets.enabled = false
    config.generators do |g|
      g.assets false
    end
  end
end
