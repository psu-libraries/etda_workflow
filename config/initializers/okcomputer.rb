require 'sidekiq/api'
OkComputer.mount_at = false

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

sidekiq_config = Rails.application.config_for(:sidekiq)

sidekiq_config['queues'].each do |q|
    threshold = sidekiq_config['latency_threshold'] || 30
    OkComputer::Registry.register "sidekiq_latency_#{q}", OkComputer::SidekiqLatencyCheck.new(q, threshold=threshold)
end

sidekiq_config['queues'].each do |q|
    threshold = sidekiq_config['size_threshold'] || 100
    OkComputer::Registry.register "sidekiq_size_#{q}", SidekiqQueueCheck.new(q, threshold=threshold)
end

## Redis Checks 

redis_config = Rails.application.config_for(:redis)

OkComputer::Registry.register "redis", OkComputer::RedisCheck.new(redis_config)