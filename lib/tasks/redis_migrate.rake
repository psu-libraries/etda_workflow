namespace :redis_migrate do

  desc 'Migrate redis db to keys with namespaces identified'
  task 'to_namespaces' => :environment do
    ns = "etda_workflow_#{current_partner}:"
    redis = Redis.current

    redis.scan_each do |key|
      begin
        new_key = [ns, key].join("")
        key.slice!(ns)

        next unless key == "schedule"

        redis.rename(key, new_key)
        schedule = redis.zrange(key, 0, -1)
        schedule.each do |record|
          if eval(record)[:args][0] > 10000

          else
            redis.rename(key, honors_new_key)
          end
        end

      rescue Redis::CommandError => e
        puts e
      end
    end
  end
end
