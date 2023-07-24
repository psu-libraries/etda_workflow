
redis_config = Rails.application.config_for(:redis)

sidekiq_config = Hash.new

sidekiq_config['password'] = redis_config['password'] if redis_config['password']
sidekiq_url = "redis://#{redis_config.fetch(:host, 'localhost')}:#{redis_config.fetch(:port, 6379)}"
sidekiq_config['url'] = sidekiq_url

Sidekiq.configure_server do |config|
  config.redis = sidekiq_config
end

Sidekiq.configure_client do |config|
  config.redis = sidekiq_config
end
