# frozen_string_literal: true

require 'lograge/sql/extension'
# require_relative '../../lib/log/formatter'

# Rails.application.configure do
#     logging_config = Rails.application.config_for(:logging)
#     config.lograge.enabled = logging_config['lograge']['enabled']
#     if logging_config['format'] == 'logstash'
#     config.lograge.formatter =  Lograge::Formatters::Logstash.new
#     end

#     if logging_config['stdout']
#     config.logger = ActiveSupport::Logger.new(STDOUT)
#     else
#     config.logger = ActiveSupport::Logger.new(Rails.root.join('log', "#{Rails.env}.log"))
#     end

#     if logging_config['format'] == 'logstash'
#     config.log_formatter = JSONFormatter.new
#     else
#     config.log_formatter = ActiveSupport::Logger::SimpleFormatter.new
#     end

#     config.logger.formatter = config.log_formatter

# end
