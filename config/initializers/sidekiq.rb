
redis_config = Rails.application.config_for(:redis)

sidekiq_config = Hash.new

sidekiq_config['password'] = redis_config['password'] if redis_config['password']
sidekiq_config['namespace'] = "etda_workflow_#{current_partner.id}"
sidekiq_url = "redis://#{redis_config.fetch('host', 'localhost')}:#{redis_config.fetch('port', 6379)}/0" if current_partner.graduate?
sidekiq_url = "redis://#{redis_config.fetch('host', 'localhost')}:#{redis_config.fetch('port', 6379)}/1" if current_partner.honors?
sidekiq_url = "redis://#{redis_config.fetch('host', 'localhost')}:#{redis_config.fetch('port', 6379)}/2" if current_partner.milsch?
sidekiq_config['url'] = sidekiq_url

Sidekiq.configure_server do |config|
  config.redis = sidekiq_config
end

Sidekiq.configure_client do |config|
  config.redis = sidekiq_config
end
