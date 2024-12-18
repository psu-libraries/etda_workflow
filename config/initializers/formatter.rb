require 'logstash-event'

class String
  def json?
    JSON.parse(self)
    true
  rescue JSON::ParserError
    false
  end
end

class JSONFormatter < ActiveSupport::Logger::SimpleFormatter
  def call(severity, timestamp, _progname, message)
    return "#{message} \n" if message.json?

    msg = { type: severity, time: timestamp, message: }
    event = LogStash::Event.new(msg).to_json
    "#{event} \n"
  end
end
