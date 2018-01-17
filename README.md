# etda_workflow

* Ruby version: 2.4.1

* System dependencies

* Configuration

    In order to use the private repository, etda_utilities, the psu-stewardship-bot token must be used.  In your local project directory, add the following line to .bundle/config with the correct token.
`BUNDLE_GEM__ETDA_UTILITIES@GITHUB__COM: "psu-stewardship-bot-tokengoeshere:x-oauth-basic"`

* To create the database, run the following commands: 
    1.  `rake db:create`
    2. `rake db:migrate`
    3. `rake db:seed:essential`  
    
* To drop the database, run `rake db:drop`

* Testing
 

   To run the tests: 
   1.  `bundle exec rspec` tests Graduate School instance   
   2.  `bundle exec PARTNER=honors rspec` tests Honors College instance
   3.  `PARTNER=milsch bundle exec rspec` tests Millennium Scholars instance

   Additionally, there are some integration tests that use  javascript and some component tests that run against Penn State's LDAP directory service: rspec --tag glacial --tag ldap. Glacial are excluded by default when running in development because they are so slow.  Ldap tests are excluded because they require connecting to the University LDAP server and should only be run occasionally.

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

    The Capistrano gem is used for deployment.
    When deploying, three instances of the application are
    deployed, one for each partner.  The following example deploys the master branch to the 'dev' server for each partner:
    `cap dev deploy_all`
    
    The following example deploys the branch named ETDA-1111 to the QA server:
    `cap qa deploy_all BRANCH_NAME=ETDA-1111`

 
