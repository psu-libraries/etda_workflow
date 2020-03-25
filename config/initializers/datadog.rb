
Datadog.configure do |c|
    # TODO maybe "tag" partner here
    release_name = ENV.fetch("RELEASE_NAME", 'etda-workflow')
    c.use :rails, service_name: release_name
    c.use :redis, service_name: "#{release_name}-redis"
    c.use :active_record, service_name: "#{release_name}-active-record"
    c.use :sidekiq, service_name: "#{release_name}-sidekiq"
end
