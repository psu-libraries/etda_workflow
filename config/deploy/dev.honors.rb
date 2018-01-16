# config/deploy/dev.honors.rb
set :stage, 'dev'
set :partner, 'honors'
set :deploy_to, "/opt/heracles/deploy/etda_workflow_honors"
set :tmp_dir, "/opt/heracles/deploy/etda_workflow_honors/tmp"
role :web,  "etdaworkflow1dev.vmhost.psu.edu:1855"
role :app,  "etdaworkflow1dev.vmhost.psu.edu:1855"
role :db,   "etdaworkflow1dev.vmhost.psu.edu:1855", primary: true # This is where Rails migrations will run
server 'etdaworkflow1dev.vmhost.psu.edu:1855', user: 'deploy', roles: %w{web}