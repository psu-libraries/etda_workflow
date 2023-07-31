namespace :redis_migrate do

  desc 'Migrate redis db to keys with namespaces identified'
  task 'to_namespaces' => :environment do
    start = Time.now
    graduate_ns = "etda_workflow_graduate:"
    honors_ns = "etda_workflow_honors:"
    redis = Redis.current

    schedule_key = redis.keys("schedule")
    graduate_schedule_key_contents = []
    honors_schedule_key_contents = []
    old_schedule_key_contents = Hash.new
    redis.zscan_each(schedule_key) do |value, score|
      old_schedule_key_contents[score] = value
    end

    count = 0
    grad_count = 0
    honors_count = 0
    old_schedule_key_contents.each do |score, value|
      if eval(value)[:args][0] > 10000
        graduate_schedule_key_contents << [score, value]
        grad_count += 1
      else
        honors_schedule_key_contents << [score, value]
        honors_count += 1
      end
      count += 1
    end

    redis.del(schedule_key)

    redis.zadd([graduate_ns, schedule_key].join(""), graduate_schedule_key_contents)
    redis.zadd([honors_ns, schedule_key].join(""), honors_schedule_key_contents)

    puts "Process completed in #{(Time.now - start)} sec.  #{count} records migrated.  #{grad_count} records migrated to graduate namespace. #{honors_count} records migrated to honors namespace."
  end

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
