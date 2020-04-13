# Electronic Theses and Dissertations Workflow [![CircleCI](https://circleci.com/gh/psu-stewardship/etda_workflow.svg?style=svg)](https://circleci.com/gh/psu-stewardship/etda_workflow)

* Ruby version: 2.6.0
* Node version 10.17.0 (using yarn@1.19.1 as npm)
 
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

### Not Docker

* System dependencies
  * rbenv 
  * mysql
  * yarn - `brew install yarn` for Mac OSX
 
* To create the database, configure it in database.yml and then run the following commands (skip 'db:seed:essential' if importing an existing database) 
    * `rails db:create`
    * `rails db:migrate`
    * `rails db:seed:essential`  
    
* To drop the database, run `rails db:drop`

* After creating the database, run `yarn` to download packages needed for assets
  In development `webpack-dev-server` can be run to watch live updating of the assets files.
  Running `RAILS_ENV=production bin/webpack` will build the manifest for production,`RAILS_ENV=development bin/webpack`, and `RAILS_ENV=test bin/webpack` for development and test manifests.  Production manifest is saved in public/assets, development manifest in public/packs and test manifest in public/packs-test.  Configuration file is config/webpacker.yml
  
  The configuration file `webpack.config.js` contains loaders and plugins for compiling css, jquery, bootstrap, etc.  It also defines where the application source files are located (app/assets/javascript/).  ETD has three sets of assets:  author, admin, and base.  Author assets are used in the author layout, Admin assets in admin, and base is used throughout the application.  The approver pack pulls from all three assets, and is used in the approver layout.
  
* To generate mocked files run `rake etda_files:create:empty_files[my_file_directory]` from the root directory.  If "my_file_directory" is not specified, the generated files will be placed in the /tmp directory by default.  

## Testing
 

   To run the tests: 
   1.  `RAILS_ENV=test bundle exec rspec` tests Graduate School instance   
   2.  `RAILS_ENV=test bundle exec PARTNER=honors rspec` tests Honors College instance
   3.  `RAILS_ENV=test PARTNER=milsch bundle exec rspec` tests Millennium Scholars instance
   
   Running the entire test suite for each partner can take a while.  To run tests for non-graduate instances that are unique to that instance, use tags like this:
   
   1. `RAILS_ENV=test PARTNER=milsch bundle exec rspec --tag milsch`
   1. `RAILS_ENV=test PARTNER=honors bundle exec rspec --tag honors`

   Additionally, there are some integration tests that use javascript and some component tests that run against Penn State's LDAP directory service: rspec --tag glacial --tag ldap. Glacial are excluded by default when running in development because they are so slow.  Ldap tests are excluded because they require connecting to the University LDAP server and should only be run occasionally.  When in development or testing, you must edit the development.rb or test.rb file in config/environments and change MockUniversityDirectory to LdapUniversityDirectory to test a true ldap call.

## Services
    
- Redis (for storing Sidekiq queues)
- Sidekiq (for delayed mailers)
- Mariadb
    

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

 
