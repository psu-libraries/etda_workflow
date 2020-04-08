# frozen_string_literal: true

# config/deploy/qa.sset.rb

set :default_env, {
    'PARTNER' => 'sset'
}

set :stage, 'qa'
set :partner, 'sset'
set :deploy_to, "/opt/deploy/etda_workflow_sset"
set :tmp_dir, "/opt/deploy/etda_workflow_sset/tmp"
role :web,  "etdaworkflow1qa.vmhost.psu.edu:1855"
role :app,  "etdaworkflow1qa.vmhost.psu.edu:1855"
role :db,   "etdaworkflow1qa.vmhost.psu.edu:1855", primary: true # This is where Rails migrations will run
server 'etdaworkflow1qa.vmhost.psu.edu:1855', user: 'deploy', roles: %w[web]
