# frozen_string_literal: true

# config/deploy/dev.sset.rb

set :default_env, {
    'PARTNER' => 'sset'
}

set :stage, 'dev'
set :partner, 'sset'
set :deploy_to, "/opt/deploy/etda_workflow_sset"
set :tmp_dir, "/opt/deploy/etda_workflow_sset/tmp"
role :web,  "etdaworkflow1dev.vmhost.psu.edu:1855"
role :app,  "etdaworkflow1dev.vmhost.psu.edu:1855"
role :db,   "etdaworkflow1dev.vmhost.psu.edu:1855", primary: true # This is where Rails migrations will run
server 'etdaworkflow1dev.vmhost.psu.edu:1855', user: 'deploy', roles: %w[web]
