require 'sidekiq/api'
OkComputer.mount_at = 'healthcheck' 

class SidekiqQueueCheck < OkComputer::SizeThresholdCheck
    attr_accessor :queue

    def initialize(queue, threshold = 100)
        self.queue = queue
        self.name = "Sidekiq queue '#{queue}' threshold"
        self.threshold = Integer(threshold)
    end

    def size
        Sidekiq::Queue.new(queue).size
    end
end

## Sidekiq Checks

sidekiq_config = YAML.load_file(Rails.root.join('config/sidekiq.yml'))

sidekiq_config['queues'].each do |q|
    OkComputer::Registry.register "sidekiq_latency_#{q}", OkComputer::SidekiqLatencyCheck.new(q)
end

sidekiq_config['queues'].each do |q|
    OkComputer::Registry.register "sidekiq_size_#{q}", SidekiqQueueCheck.new(q)
end

## Redis Checks 

redis_config = YAML.load(ERB.new(IO.read(File.join(Rails.root, 'config', 'redis.yml'))).result)[Rails.env].with_indifferent_access

OkComputer::Registry.register "redis", OkComputer::RedisCheck.new(redis_config)