#!/bin/bash

# As deploy user, run decouple.sh graduate, decouple.sh honors, decouple.sh milsch.  These can run simultaneously
# When running the script, be sure to be in the correct partner's directory i.e. etda_workflow_honors/current for honors

if  [ "$1" != "graduate" ] && [ "$1" != "honors" ] && [ "$1" != "milsch" ]
 then echo "Aborting - please enter a partner (graduate, honors, or milsch)"; exit;
fi

echo "Migrating Partner $1"

cd etda_workflow_$1/current

##if solr is running, it should be stopped; need root privs; could occur before starting the script
##echo 'Stopping solr'
##sudo service solr stop
##echo 'Solr stopped'

echo 'Deleting Workflow Files'
rm -r workflow_data_files/*
echo 'Deleting Explore Files'
rm -r explore_data_files/*
echo 'Files deleted'

echo 'Create list of duplicate authors in legacy database'
RAILS_ENV=production PARTNER=$1 bin/rails db_update:dups:fix_authors[legacy,dry_run] >> log/duplicate_legacy_authors.log

echo "Dropping $1 database"
RAILS_ENV=production PARTNER=$1 bin/rails db:drop
RAILS_ENV=production PARTNER=$1 bin/rails db:create
RAILS_ENV=production PARTNER=$1 bin/rails db:migrate
echo "Empty $1 database created"

##this could occur before starting the script
##echo 'Stopping Chef'
##Disable Chef on server /etc/cron.d/chef    *****comment the line? what's the preferred method to disable?
##echo 'Chef disabled'

echo "Importing legacy $1 database"
RAILS_ENV=production PARTNER=$1 bin/rails legacy:import:all_data
echo "Database import for $1 complete"

echo "Importing $1 legacy files"
RAILS_ENV=production PARTNER=$1 bin/rails legacy:import:all_files[stage]
echo "File import for $1 complete"

echo 'Verify file import'
RAILS_ENV=production PARTNER=$1 bin/rails final_files:verify
echo "Results in etda_workflow_$1/current/log/`date +"%Y-%m-%d"`.log"

##need root privileges for this
##echo "Start solr"
##sudo service solr start
##echo "Solr started"

#as deploy user
echo "Performing Solr full import for $1"
RAILS_ENV=production PARTNER=$1 bin/rails workflow:solr:full_import
echo "Solr import complete; Results in etda_workflow_$1/current/log/solr_production.log"

##need root privileges for this
##echo 'Start Chef'
##restart chef

echo "$1 decouple migration complete"

