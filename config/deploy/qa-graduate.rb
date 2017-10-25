set :stage, fetch(:vstage, 'qa')
set :deploy_to, "/opt/heracles/deploy/#{application}-graduate"
role :web,  "etdaworkflow1dev.vmhost.psu.edu:1855"
role :app,  "etdaworkflow1dev.vmhost.psu.edu:1855"
role :solr, "etdaworkflow1dev.vmhost.psu.edu:1855" # This is where resolrize will run
role :db,   "etdaworkflow1dev.vmhost.psu.edu:1855", primary: true # This is where Rails migrations will run
