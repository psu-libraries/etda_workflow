namespace :redis_migrate do

  desc 'Migrate redis db to remove namespaces'
  task 'remove_namespaces' => :environment do
    # This script migrates data from a single namespaced redis 
    # instance to multiple distinct redis instances for each partner 

    # Setup redis connection
    redis_config = RedisClient.config(**Rails.application.config_for(:redis))
    redis = redis_config.new_pool(timeout: 0.5, size: 5)

    # Rename all keys including this partner's namespace to the original key with namespace removed
    redis.call("KEYS", "etda_workflow_#{current_partner.id}*").each do |key| 
      redis.call("RENAME", key, key.gsub("etda_workflow_#{current_partner.id}:", ''))
    end

    # Delete all the keys still containing a namespace, hence deleting other partner's keys
    redis.call("KEYS", "*").each do |key|
      redis.call("DEL", key) if key.include?('etda_workflow')
    end
  end
end
