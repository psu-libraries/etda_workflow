#!/bin/bash

# As deploy user, run decouple.sh graduate, decouple.sh honors, decouple.sh milsch.  These can run simultaneously
# Before running this script, stop Solr (service solr stop), stop Chef

if  [ "$1" != "graduate" ] && [ "$1" != "honors" ] && [ "$1" != "milsch" ]
 then echo "Aborting - please enter a partner (graduate, honors, or milsch)"; exit;
fi

echo "Migrating Partner $1"

cd /opt/deploy/etda_workflow_$1/current

# Existing files must be deleted before import
echo 'Deleting Workflow Files'
rm -r workflow_data_files/*
echo 'Deleting Explore Files'
rm -r explore_data_files/*
echo 'Files deleted'

echo 'Create list of duplicate authors in legacy database'
RAILS_ENV=production PARTNER=$1 bin/rails db_update:dups:fix_authors[legacy,dry_run] >> log/duplicate_legacy_authors.log

# Database must be empty before import
echo "Dropping $1 database"
RAILS_ENV=production PARTNER=$1 bin/rails db:drop DISABLE_DATABASE_ENVIRONMENT_CHECK=1
RAILS_ENV=production PARTNER=$1 bin/rails db:create
RAILS_ENV=production PARTNER=$1 bin/rails db:migrate
echo "Empty $1 database created"

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

#as deploy user run commands to build core; can also use web interface
# echo "Performing Solr full import for $1"
# RAILS_ENV=production PARTNER=$1 bin/rails workflow:solr:full_import
# echo "Solr import complete; Results in etda_workflow_$1/current/log/solr_production.log"

##need root privileges for this
##echo 'Start Chef'
##restart chef

echo "$1 decouple migration complete"

