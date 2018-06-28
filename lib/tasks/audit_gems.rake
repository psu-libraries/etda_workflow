# frozen_string_literal: true
require 'bundler/audit/task'

namespace :audit do
  desc "Check gems for vulnerabilites; this task is used for whenever"
  task gems: :environment do
    time_out = Time.zone.now.to_s
    output = `bundle exec bundle audit check --update`
    final_output = output + '--- at ' + time_out
    send_notification(final_output) unless no_vulnerabilities_found(output)
    puts final_output
  end

  def no_vulnerabilities_found(output)
    return false unless output.include? 'No vulnerabilities found'
    true
  end

  def send_notification(output)
    WorkflowMailer.gem_audit_email(output.remove('\n', '<br>')).deliver_now
  end
end
