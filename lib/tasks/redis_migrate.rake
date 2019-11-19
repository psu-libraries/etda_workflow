namespace :redis_migrate do

  desc 'Migrate redis db to keys with namespaces identified'
  task 'to_namespaces' => :environment do
    ns = "etda_workflow_#{current_partner.id}:"
    redis = Redis.current

    redis.scan_each do |key|
      begin
        new_key = [ns, key].join("")
        key.slice!(ns)
        redis.rename(key, new_key)

      rescue Redis::CommandError => e
        puts e
      end
    end
  end
end
