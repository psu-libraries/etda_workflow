
require_relative '../../lib/healthchecks/queue_latency_check'
require_relative '../../lib/healthchecks/queue_dead_set_check'

OkComputer.mount_at = false

OkComputer::Registry.register(
  'sidekiq',
  HealthChecks::QueueLatencyCheck.new(ENV.fetch('SIDEKIQ_QUEUE_LATENCY_THRESHOLD', 30).to_i)
)

OkComputer::Registry.register(
  'sidekiq_deadset',
  HealthChecks::QueueDeadSetCheck.new
)

# If you want to keep the size check, you can add it here, but scholarsphere does not have it:
# OkComputer::Registry.register(
#   'sidekiq_size',
#   HealthChecks::QueueSizeCheck.new(ENV.fetch('SIDEKIQ_QUEUE_SIZE_THRESHOLD', 100).to_i)
# )

OkComputer.make_optional %w(sidekiq sidekiq_deadset)
