#!/bin/bash

# As deploy user, run decouple.sh graduate, decouple.sh honors, decouple.sh milsch.  These can run simultaneously
# Before running this script, stop Solr (service solr stop)
# Stop Chef

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
# Author import errors will occur when duplicate records are encountered
# Use this list to compare to errors that occur when importing authors
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

#check logs and compare author input errors to duplication authors list

echo "Importing $1 legacy files"
RAILS_ENV=production PARTNER=$1 bin/rails legacy:import:all_files[prod,verify_files]
echo "File import for $1 complete"

echo 'Verify file import'
RAILS_ENV=production PARTNER=$1 bin/rails final_files:verify
echo "Results in etda_workflow_$1/current/log/`date +"%Y-%m-%d"`.log"

#remaining steps to be completed by outside of script
##start solr
##need root privileges for this
##sudo service solr start

#as deploy user run commands to build core; can also use web interface
# RAILS_ENV=production PARTNER=$1 bin/rails workflow:solr:full_import

#At this point the DNS Name for explore should be updated and Apache rewrites from current production server to new explore server
#Deploy an updated version of etda_workflow that builds explore production URLs correctly:  etda.libraries.psu.edu, honors.libraries.psu.ed, millennium-scholars.libraries.psu.edu
#rather than etda_explore_prod..., honors_explore_prod..., etc.

##need root privileges for this
##start chef


