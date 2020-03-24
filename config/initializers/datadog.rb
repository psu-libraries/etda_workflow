
Datadog.configure do |c|
    # TODO maybe "tag" partner here
    c.use :rails, service_name: ENV.fetch("RELEASE_NAME", 'etda-workflow')
end