require_relative 'boot'

require 'rails/all'
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module EtdaWorkflow
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # moved lib/devise to app/lib/devise to bypass eagerload/autoload issue rails 5
    # config.eager_load_paths << "#{Rails.root}/lib/**/*"

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    #
    config.time_zone = 'Eastern Time (US & Canada)'

    # config.autoload_paths += Dir["#{config.root}/lib/**/*"]
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', 'partners', I18n.default_locale.to_s, '*', '*.{rb,yml}').to_s]
  end
end
