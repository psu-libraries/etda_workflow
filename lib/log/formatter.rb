require 'logstash-event'

class String
    def is_json?
        begin
            JSON.parse(self)
        rescue
            false
        end
    end
end

class JSONFormatter < ActiveSupport::Logger::SimpleFormatter
    def call(severity, timestamp, _progname, message)
        return "#{message} \n" if message.is_json?

        msg = { type: severity, time: timestamp, message: message }
        event = LogStash::Event.new(msg).to_json
        "#{event} \n"
    end
end