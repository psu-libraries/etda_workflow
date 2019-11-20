namespace :redis_migrate do

  desc 'Migrate redis db to keys with namespaces identified'
  task 'to_namespaces' => :environment do
    start = Time.now
    graduate_ns = "etda_workflow_graduate:"
    honors_ns = "etda_workflow_honors:"
    milsch_ns = "etda_workflow_milsch:"
    redis = Redis.current

    schedule_key = redis.keys("schedule")
    graduate_schedule_key_contents = []
    honors_schedule_key_contents = []
    old_schedule_key_contents = redis.zrange(schedule_key, 0, -1)

    count = 0
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
      count += 1
    end

    redis.del(schedule_key)

    redis.zadd([graduate_ns, schedule_key].join(""), graduate_schedule_key_contents)
    redis.zadd([honors_ns, schedule_key].join(""), honors_schedule_key_contents)
    redis.zadd([milsch_ns, schedule_key].join(""), [[0, ""]])

    puts "Process completed in #{(Time.now - start)} sec.  #{count} records migrated.  #{grad_count} records migrated to graduate namespace. #{honors_count} records migrated to honors namespace."
  end
end
