# frozen_string_literal: true
set :environment, :production
set :partner, current_partner
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

every :day, at: '1am', roles: [:app]  do
  rake 'tokens:remove_expired'
end

every :day, at: '1am', roles: [:app]  do
  rake 'confidential:update'
end
