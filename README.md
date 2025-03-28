[![CircleCI](https://circleci.com/gh/psu-libraries/etda_workflow.svg?style=svg)](https://circleci.com/gh/psu-stewardship/etda_workflow)
[![Maintainability](https://api.codeclimate.com/v1/badges/a38c9040c48fe53aaa85/maintainability)](https://codeclimate.com/github/psu-libraries/etda_workflow/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/a38c9040c48fe53aaa85/test_coverage)](https://codeclimate.com/github/psu-libraries/etda_workflow/test_coverage)

# Electronic Theses and Dissertations Workflow

* Ruby version: 3.4.1
* Node version 21.7.3 (using yarn as npm)
* Rails 7.2
* Sidekiq 7
* Redis 6.2+

## Setup

Clone the repo to your local device and `cd` to the project root directory

If you do not have direnv, use brew to install 

Run `vi .envrc` and add environment variables

### Docker

*Run `make` or view the Makefile for target definitions*

To build the image and run necessary containers:

 1. `docker-compose build`
 2. `docker-compose up -d selenium db redis web`
 3. Check it out at `localhost:3000` in your browser

To copy database data into container:

1. Retrieve an sql dump or compressed backup of the prod or staging database
2. `docker cp /path/to/file.sql.gz {db_container}:/`
3. `docker-compose exec db bash`
4. Unzip file if compressed using `gunzip`
5. `mysql -u root -p -D {database_name} < /path/to/file.sql`

To create mock submission files:

*This should be done after the database data is created, or else nothing will be created*

1. `docker-compose exec web bash` (running bash in the web container)
2. `rake etda_files:create:empty_files` (this may take a while)

To seed data:

1. `docker-compose exec web bash`
2. `PARTNER={parter} bundle exec rake db:seed:essential`

**_Note:_** For new devs you may need to add their `Author` and `Admin` records manually.  Alternatively, you can comment out the `MockUniversityDirectory` line
 in `config/initializers/autoload_constants.rb` for the development environment.  Then proceed to the admin and author routes to automatically create the records with LDAP.

You're good to go from here!  Any changes made in the project files on your local machine will automatically be updated in the container.  Run `make restart` to restart the puma server if changes do not appear in the web browser.  Remember to check the Makefile for more commands.  If you are running a shell in the web container, you can run all of the rails commands you would normally use for development: ie `rspec, rails restart, rails c, etc.`

## Testing

   To run the tests:
   1.  `RAILS_ENV=test bundle exec rspec` tests Graduate School instance   
   2.  `RAILS_ENV=test PARTNER=honors bundle exec rspec` tests Honors College instance
   3.  `RAILS_ENV=test PARTNER=milsch bundle exec rspec` tests Millennium Scholars instance

   Running the entire test suite for each partner can take a while.  To run tests for non-graduate instances that are unique to that instance, use tags like this:

   1. `RAILS_ENV=test PARTNER=milsch bundle exec rspec --tag milsch`
   1. `RAILS_ENV=test PARTNER=honors bundle exec rspec --tag honors`

   Additionally, there are some component tests that run against Penn State's LDAP directory service: rspec --tag ldap. Ldap tests are excluded because they require connecting to the University LDAP server and should only be run occasionally.  When in development or testing, you must edit the `config/initializers/autoload_constants.rb` file and comment out the `MockUniversityDirectory` lines for the development and test environments to allow a true ldap call.

## Deployment instructions

To deploy a preview, prepend your branch name with `preview/` like so: `preview/your-branch-name`. A preview will deploy when you push this branch to GitHub.

Any PRs merged to main will automatically be deployed to QA.

To initiate a production deploy, create a new release. Then, merge the automatically created PR in the config repo: https://github.com/psu-libraries/etda-config

### Config
The [config](https://rubygems.org/gems/config) gem provides a means for adding ad-hoc config as needed.
The file `config/settings.local.yml` is not tracked in git. 
Currently this is used to add announcements quickly. By adding values such as:
```rb
# Strings
show_announcement: true
announcement:
  header: "Announcement header text goes here"
  message: "Place your important message here"
```

## LionPath Integration

### Imports

Student program and committee information is imported daily from LionPath.  The integration runs on a cron job that kicks off at 3am.  There are 4 tables/resources updated in ETDA by this daily import: Submission, Program, CommitteeMember, CommitteeRole.  The import works in the following order:

1. Committee Roles for The Graduate School's Dissertation submissions are imported.  This updates the CommitteeRole table with changes and/or new committee roles.  These roles exactly reflect the roles in LionPath and are different from Master's Thesis roles.

2. Student program information is imported for The Graduate School's Master's Thesis and Dissertation submissions.  New programs are added to the Program table during this import and linked to the student's Submission.

3. Committees are imported for The Graduate School's Dissertation submissions.  This adds or updates CommitteeMembers for the student's submission.  These committees use the Committee Roles imported previously from LionPath.

Committees and Committee Roles are not currently being imported from LionPath for The Graduate School's Master's Thesis submissions.

The LionPath integration uses sftp to pull CSV dumps of the Committee Roles, Student Program info, and Committees (in that order) from LionPath.  The files follow these file naming conventions:

	Committee Roles: PE_SR_G_ETD_ACT_COMROLES
	Student Program Information: PE_SR_G_ETD_STDNT_PLAN_PRC
	Committees: PE_SR_G_ETD_COMMITTEE_PRC
	
After each run of this import, `Submission` and `CommitteeMember` records imported from LionPath are checked to see if they should be deleted.  Any `Submission` still at the collecting program information stage that has not been updated by LionPath in the last two days will be deleted.  Any `CommitteeMember` that is not external to PSU, not a program head, not associated with a `Submission` beyond the final submission review stage, and hasn't been updated by LionPath in two days will also be deleted. There is a failsafe that stops the deletion if more than 10% of records are being deleted.

### Exports

LionPath has a REST API for ingesting data for submissions (student plans in LionPath).  We export data to LionPath throughout the submission process to keep LionPath up-to-date on the student's progress.

The exports are triggered in three places:

1. When a Submission transitions state in the workflow progression. For instance, when an author submits the format review form transitioning that submission from 'collecting format review files' to 'waiting for format review response'.
2. When an admin makes edits
3. When a submission's publication date is extended

The exports are ran as async jobs with sidekiq. This prevents the exports from affecting the user experience and allows us to rerun them if they fail. They are delayed by 1 minute to ensure updates to the database are complete before sending the data. Only one job per submission can be queued at a time. Multiple exports at once with the same submission causes issues with Lionpath.

The submission's `candidate_number` (imported from LionPath) and the author's PSU ID (9 digit number) are used to identify the record in LionPath to update.

By default the exports don't run in development and test environments.  If you want to toggle the exports on, set the `LP_EXPORT_TEST` environment variable to true.

## Graduate School Fee

Master's Thesis and Dissertation submissions require a fee to be paid in the Graduate School's systems before students can proceed with submission of their final submission.  The eTD system checks this via a webservice endpoint in the Graduate School's systems and blocks users from proceeding if the fee is not paid.  This functionality is turned off in development and QA environments.  The logic to determine if the code is running in one of these environments can be found in `config/environment.rb`.
