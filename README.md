[![CircleCI](https://circleci.com/gh/psu-stewardship/etda_workflow.svg?style=svg)](https://circleci.com/gh/psu-stewardship/etda_workflow)
[![Maintainability](https://api.codeclimate.com/v1/badges/a38c9040c48fe53aaa85/maintainability)](https://codeclimate.com/github/psu-stewardship/etda_workflow/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/a38c9040c48fe53aaa85/test_coverage)](https://codeclimate.com/github/psu-stewardship/etda_workflow/test_coverage)

# Electronic Theses and Dissertations Workflow 

* Ruby version: 2.6.6
* Node version 10.17.0 (using yarn@1.19.1 as npm)
* Rails 6.0.3.1
* Redis 3.2.12
* Sidekiq 5.2.8
* Mariadb 10.2
 
## Setup

Clone the repo to your local device and `cd` to the project root directory

### Docker

*Run `make` or view the Makefile for target definitions*

To build the image and run containers:

 1. `make build`
 2. `make up`
 3. Check it out at `localhost:3000` in your browser
    
To copy database data into container:

1. Retrieve an sql dump or compressed backup of the prod or staging database
2. `docker cp /path/to/file.sql.gz {db_container}:/`
3. `docker-compose exec db bash` 
4. Unzip file if compressed using `gunzip`
5. `mysql -u root -p -D {database_name} < /path/to/file.sql` 
    
To create mock submission files:

*This should be done after the database data is created, or else nothing will be created*

1. `make exec` (running bash in the web container)
2. `rake etda_files:create:empty_files` (this may take a while)

To seed data:

1. `make exec`
2. `PARTNER={parter} bundle exec rake db:seed:essential`
    
You're good to go from here!  Any changes made in the project files on your local machine will automatically be updated in the container.  Run `make restart` to restart the puma server if changes do not appear in the web browser.  Remember to check the Makefile for more commands.  If you are running a shell in the web container, you can run all of the rails commands you would normally use for development: ie `rspec, rails restart, rails c, etc.`

## Testing
 

   To run the tests: 
   1.  `RAILS_ENV=test bundle exec rspec` tests Graduate School instance   
   2.  `RAILS_ENV=test bundle exec PARTNER=honors rspec` tests Honors College instance
   3.  `RAILS_ENV=test PARTNER=milsch bundle exec rspec` tests Millennium Scholars instance
   
   Running the entire test suite for each partner can take a while.  To run tests for non-graduate instances that are unique to that instance, use tags like this:
   
   1. `RAILS_ENV=test PARTNER=milsch bundle exec rspec --tag milsch`
   1. `RAILS_ENV=test PARTNER=honors bundle exec rspec --tag honors`

   Additionally, there are some integration tests that use javascript and some component tests that run against Penn State's LDAP directory service: rspec --tag ldap. Ldap tests are excluded because they require connecting to the University LDAP server and should only be run occasionally.  When in development or testing, you must edit the development.rb or test.rb file in config/environments and change MockUniversityDirectory to LdapUniversityDirectory to test a true ldap call.

## Deployment instructions

The Capistrano gem is used for deployment.
When deploying, three instances of the application are
deployed, one for each partner.  The following example deploys the master branch to the 'dev' server for each partner:
`cap dev deploy_all`

The following example deploys the branch named ETDA-1111 to the QA server:
`cap qa deploy_all BRANCH_NAME=ETDA-1111`

To run tasks on the server, use the "invoke" namespace and the "rake" or "command" tasks to run rake tasks or bash commands respectively.  "rake" or "command" will invoke a rake task or bash command for a single specified stage + partner.  "rake_all" or "command_all" will invoke a rake task or bash command across all partners for a specified stage.  Ex:

    cap dev invoke:rake_all[db:seed:essential]
    cap dev.graduate invoke:command['cat Gemfile.lock']
    
*Note: When running bash commands, the parameter to "invoke:command[]" should be in single quotes.*

If using ssh to run tasks on the server, be sure to set the PARTNER environment variable for partner specific tasks.
    
When updating rails versions, be sure to rebuild webpack binary `bundle exec bin/rails webpacker:binstubs
` respond with 'Y' to overwrite existing webpack & webpacker binaries    

## LionPATH Integration

Student program information is imported daily from LionPATH for The Graduate School's Master's Thesis and Dissertation submissions.

Program Head/Chair data is imported daily from LionPATH and is used to update a submission's Program Head/Chair information daily for The Graduate School's Master's Thesis and Dissertation submissions.

Committee Roles for The Graduate School's Dissertation submissions are imported daily from LionPATH.  These roles exactly reflect the roles in LionPATH and are different from Master's Thesis roles.

Committees are also imported daily for The Graduate School's Dissertation submissions.  These committees use the Committee Roles imported previously from LionPATH.

Committees are not currently being imported from LionPATH for The Graduate School's Master's Thesis submissions.

The LionPATH integration uses sftp to pull CSV dumps of the Committee Roles, Student Program data(submissions), Program Head/Chair, and Committees (in that order) from LionPATH.  The bash script: `lionpath-csv.sh` does most of the work to grab these CSVs from the LionPATH sftp server.  The files follow these file naming conventions:

	Committee Roles: PE_SR_G_ETD_ACT_COMROLES
	Student Program Information: PE_SR_G_ETD_STDNT_PLAN_PRC
	Program Head/Chair: PE_SR_G_ETD_CHAIR_PRC
	Committees: PE_SR_G_ETD_COMMITTEE_PRC
