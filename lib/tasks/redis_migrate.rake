namespace :redis_migrate do

  desc 'Migrate redis db to keys with namespaces identified'
  task 'to_namespaces' => :environment do
    graduate_ns = "etda_workflow_graduate:"
    honors_ns = "etda_workflow_honors:"
    milsch_ns = "etda_workflow_milsch:"
    redis = Redis.current

    schedule_key = redis.keys("schedule")
    graduate_schedule_key_contents = []
    honors_schedule_key_contents = []
    old_schedule_key_contents = redis.zrange(schedule_key, 0, -1)

    grad_count = 0
    honors_count = 0
    old_schedule_key_contents.each do |record|
      if eval(record)[:args][0] > 10000
        graduate_schedule_key_contents << [grad_count, record]
        grad_count += 1
      else
        honors_schedule_key_contents << [honors_count, record]
        honors_count += 1
      end
    end

    redis.del(schedule_key)

    redis.zadd([graduate_ns, schedule_key].join(""), graduate_schedule_key_contents)
    redis.zadd([honors_ns, schedule_key].join(""), honors_schedule_key_contents)
    redis.zadd([milsch_ns, schedule_key].join(""), [[0, ""]])

    # redis.scan_each do |key|
    #   begin
    #     new_key = [ns, key].join("")
    #     key.slice!(ns)
    #
    #     next unless key == "schedule"
    #
    #     redis.rename(key, new_key)
    #     schedule = redis.zrange(key, 0, -1)
    #     schedule.each do |record|
    #       if eval(record)[:args][0] > 10000
    #
    #       else
    #         redis.rename(key, honors_new_key)
    #       end
    #     end
    #
    #   rescue Redis::CommandError => e
    #     puts e
    #   end
    # end
  end
end
