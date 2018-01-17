# frozen_string_literal: true

# Use this file to easily define all of your cron jobs.
set :output, "#{path}/log/wheneveroutput.log"

every :hour, roles: [:db] do
  rake 'etda:dih:delta_import'
end
