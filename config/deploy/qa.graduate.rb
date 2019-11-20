# frozen_string_literal: true

# config/deploy/qa.graduate.rb

set :default_env, {
    'PARTNER' => 'graduate'
}

set :stage, 'qa'
set :partner, 'graduate'
set :deploy_to, "/opt/deploy/etda_workflow_graduate"
set :tmp_dir, "/opt/deploy/etda_workflow_graduate/tmp"
role :web, "etdaworkflow1qa.vmhost.psu.edu:1855"
role :app,  "etdaworkflow1qa.vmhost.psu.edu:1855"
role :db,   "etdaworkflow1qa.vmhost.psu.edu:1855", primary: true # This is where Rails migrations will run
role :audit, "etdaworkflow1qa.vmhost.psu.edu:1855" # this is where bundle:audit runs
server 'etdaworkflow1qa.vmhost.psu.edu:1855', user: 'deploy', roles: %w[web]
