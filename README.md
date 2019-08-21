# etda_workflow

[![Build Status](https://travis-ci.com/psu-stewardship/etda_workflow.svg?token=aQpc68FoUpxpqgvP9XN9&branch=master)](https://travis-ci.com/psu-stewardship/etda_workflow)

* Ruby version: 2.4.3

* System dependencies
  * rbenv 
  * mysql
  * yarn - `brew install yarn` for Mac OSX

* Configuration

    In order to use the private repository, etda_utilities, the psu-stewardship-bot token must be used.  In your local project directory, add the following line to .bundle/config with the correct token.
`BUNDLE_GEM__ETDA_UTILITIES@GITHUB__COM: "psu-stewardship-bot-tokengoeshere:x-oauth-basic"`

* To create the database, configure it in database.yml and then run the following commands (skip 'db:seed:essential' if importing an existing database) 
    * `rails db:create`
    * `rails db:migrate`
    * `rails db:seed:essential`  
    
* To drop the database, run `rails db:drop`

* After creating the database, run `yarn` to download packages needed for assets
  In development `webpack-dev-server` can be run to watch live updating of the assets files.
  Running `RAILS_ENV=production bin/webpack` will build the manifest for production,`RAILS_ENV=development bin/webpack`, and `RAILS_ENV=test bin/webpack` for development and test manifests.  Production manifest is saved in public/assets, development manifest in public/packs and test manifest in public/packs-test.  Configuration file is config/webpacker.yml
  
  The configuration file `webpack.config.js` contains loaders and plugins for compiling css, jquery, bootstrap, etc.  It also defines where the application source files are located (app/assets/javascript/).  ETD has three sets of assets:  author, admin, and base.  Author assets are used in the author layout, Admin assets in admin, and base is used throughout the application.

* Testing
 

   To run the tests: 
   1.  `bundle exec rspec` tests Graduate School instance   
   2.  `bundle exec PARTNER=honors rspec` tests Honors College instance
   3.  `PARTNER=milsch bundle exec rspec` tests Millennium Scholars instance

   Additionally, there are some integration tests that use  javascript and some component tests that run against Penn State's LDAP directory service: rspec --tag glacial --tag ldap. Glacial are excluded by default when running in development because they are so slow.  Ldap tests are excluded because they require connecting to the University LDAP server and should only be run occasionally.  When in development, you must edit the development.rb file in config/environments and change MockUniversityDirectory to LdapUniversityDirectory to test a true ldap call.

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

    The Capistrano gem is used for deployment.
    When deploying, three instances of the application are
    deployed, one for each partner.  The following example deploys the master branch to the 'dev' server for each partner:
    `cap dev deploy_all`
    
    The following example deploys the branch named ETDA-1111 to the QA server:
    `cap qa deploy_all BRANCH_NAME=ETDA-1111`
    
* When updating rails versions, be sure to rebuild webpack binary `bundle exec bin/rails webpacker:binstubs
` respond with 'Y' to overwrite existing webpack & webpacker binaries    

 
