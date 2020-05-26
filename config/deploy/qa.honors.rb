# frozen_string_literal: true

# config/deploy/qa.honors.rb

set :default_env, {
    'PARTNER' => 'honors'
}

set :stage, 'qa'
set :partner, 'honors'
set :deploy_to, "/opt/deploy/etda_workflow_honors"
set :tmp_dir, "/opt/deploy/etda_workflow_honors/tmp"
role :web,  "etdaworkflow1qa.vmhost.psu.edu:1855"
role :app,  "etdaworkflow1qa.vmhost.psu.edu:1855"
role :db,   "etdaworkflow1qa.vmhost.psu.edu:1855", primary: true # This is where Rails migrations will run
server 'etdaworkflow1qa.vmhost.psu.edu:1855', user: 'deploy', roles: %w[web]
