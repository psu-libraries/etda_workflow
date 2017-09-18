set :stage, fetch(:vstage, 'qa')
set :deploy_to, "/opt/heracles/deploy/#{application}-honors"
role :web,  "etda1qa.vmhost.psu.edu:1855"
role :app,  "etda1qa.vmhost.psu.edu:1855"
role :solr, "etda1qa.vmhost.psu.edu:1855" # This is where resolrize will run
role :db,   "etda1qa.vmhost.psu.edu:1855", primary: true # This is where Rails migrations will run
