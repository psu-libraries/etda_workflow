# frozen_string_literal: true
set :environment, :production
# Use this file to easily define all of your cron jobs.
set :output, "#{path}/log/wheneveroutput.log"

# every :hour, roles: [:db] do
  # rake 'etda:dih:delta_import'
# end

every :day, roles: [:audit]  do
  rake 'audit:gems'
end

every :sunday, at: '1am', roles: [:app] do
  rake 'final_files:verify'
end
