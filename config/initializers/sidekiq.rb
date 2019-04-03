Sidekiq.configure_server do |config|
  config.redis = { password: "#{Rails.application.config_for(:redis)['password']}" } unless Rails.env = 'development'
end

Sidekiq.configure_client do |config|
  config.redis = { password: "#{Rails.application.config_for(:redis)['password']}" } unless Rails.env = 'development'
end