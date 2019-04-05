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

sidekiq_config['queues'].each do |k, v |
    threshold = 30
    if v
        threshold = sidekiq_config['queues'][k]['max_queue_latency'] || 30
    end
    OkComputer::Registry.register "sidekiq_latency_#{k}", OkComputer::SidekiqLatencyCheck.new(k, threshold=threshold)
end

sidekiq_config['queues'].each do |k, v|
    threshold = 100
    if v
        threshold = sidekiq_config['queues'][k]['max_queue_size'] || 100
    end
    OkComputer::Registry.register "sidekiq_size_#{k}", SidekiqQueueCheck.new(k, threshold=threshold)
end

## Redis Checks 

redis_config = YAML.load(ERB.new(IO.read(File.join(Rails.root, 'config', 'redis.yml'))).result)[Rails.env].with_indifferent_access

OkComputer::Registry.register "redis", OkComputer::RedisCheck.new(redis_config)