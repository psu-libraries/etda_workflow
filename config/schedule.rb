# frozen_string_literal: true
set :environment, :production
# Use this file to easily define all of your cron jobs.
set :output, "#{path}/log/wheneveroutput.log"

# every :hour, roles: [:db] do
  # rake 'etda:dih:delta_import'
# end

job_type :partner_rake,    "cd :path && :environment_variable=:environment PARTNER=:partner bundle exec rake :task --silent :output"

every :day, roles: [:audit]  do
  partner_rake 'audit:gems'
end

every :sunday, at: '1am', roles: [:app] do
  partner_rake 'final_files:verify'
end

every :day, at: '1am', roles: [:app]  do
  partner_rake 'tokens:remove_expired'
end

every :day, at: '1am', roles: [:app]  do
  partner_rake 'confidential:update'
end
