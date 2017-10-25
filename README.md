# README

This README would normally document whatever steps are necessary to get the
application up and running.

* Ruby version: 2.4.1

* System dependencies

* Configuration
In order to use the private repository, etda_utilities, the psu-stewardship-bot token must be used.  In your local project directory, add the following line to .bundle/config with the correct token.
`BUNDLE_GEM__ETDA_UTILITIES@GITHUB__COM: "psu-stewardship-bot-tokengoeshere:x-oauth-basic"`
* To create the database, run the following commands: `rake db:create` followed by `rake db:migrate`
* To drop the database, run `rake db:drop`

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* Testing  

To run the tests: rspec runs graduate tests; PARTNER=honors rspec runs honors
 PARTNER=milsch rspec runs milsch

Additionally, there are some integration tests that use javascript and some component tests that run against Penn State's LDAP directory service: rspec --tag glacial --tag ldap. Glacial are excluded by default when running in development because they are so slow.  Ldap tests are excluded because they require connecting to the University LDAP server and should only be run occasionally.


# etda_workflow
