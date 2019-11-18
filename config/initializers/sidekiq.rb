#
# redis_config = Rails.application.config_for(:redis)
#
# sidekiq_config = Hash.new
#
# sidekiq_config['password'] = redis_config['password'] if redis_config['password']
# sidekiq_config['db'] = 0 if current_partner.graduate?
# sidekiq_config['db'] = 1 if current_partner.honors?
# sidekiq_config['db'] = 2 if current_partner.milsch?
# sidekiq_url = "redis://#{redis_config.fetch('host', 'localhost')}:#{redis_config.fetch('port', 6379)}/#{sidekiq_config['db']}"
# sidekiq_config['url'] = sidekiq_url
#
# Sidekiq.configure_server do |config|
#   config.redis = sidekiq_config
# end
#
# Sidekiq.configure_client do |config|
#   config.redis = sidekiq_config
# end

Sidekiq.configure_server do |config|
  config.redis = {
      url: 'redis://127.0.0.1:6379/1',
      db: 1
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
      url: 'redis://127.0.0.1:6379/1',
      db: 1
  }
end

Sidekiq.configure_server do |config|
  config.redis = {
      url: 'redis://127.0.0.1:6379/2',
      db: 2
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
      url: 'redis://127.0.0.1:6379/2',
      db: 2
  }
end

Sidekiq.configure_server do |config|
  config.redis = {
      url: 'redis://127.0.0.1:6379/3',
      db: 3
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
      url: 'redis://127.0.0.1:6379/3',
      db: 3
  }
end