# config/deploy/dev.graduate.rb
set :stage, :dev
set :partner, 'graduate'
set :deploy_to, "/opt/heracles/deploy/etda_workflow_graduate"
set :tmp_dir, "/opt/heracles/deploy/etda_workflow_graduate/tmp"
role :web, %w{deploy@etdaworkflow1dev.vmhost.psu.edu:1855}
role :app,  "etdaworkflow1dev.vmhost.psu.edu:1855"
role :db,   "etdaworkflow1dev.vmhost.psu.edu:1855", primary: true # This is where Rails migrations will run
server 'etdaworkflow1dev.vmhost.psu.edu:1855', user: 'deploy', roles: %w{web}