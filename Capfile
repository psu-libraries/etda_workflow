# frozen_string_literal: true

# Load DSL and set up stages
require "capistrano/setup"

# Include default deployment tasks
require "capistrano/deploy"

# Load the SCM plugin appropriate to your project:
#
# require "capistrano/scm/hg"
# install_plugin Capistrano::SCM::Hg
# or
# require "capistrano/scm/svn"
# install_plugin Capistrano::SCM::Svn
# or
#
# # require 'capistrano/rvm'
require 'capistrano/rbenv' # rbenv setup
require 'capistrano/rails' # rails (includes bundler, rails/assets and rails/migrations)
require 'capistrano/scm/git'
install_plugin Capistrano::SCM::Git
require 'whenever/capistrano' # whenever
require 'capistrano-resque' # resque
require 'capistrano/rbenv_install' # rbenv install plugin
require 'capistrano/rails/migrations'
require 'capistrano/passenger'
require 'capistrano/yarn'

# Include tasks from other gems included in your Gemfile
#
# For documentation on these, see for example:
#
#   https://github.com/capistrano/rvm
#   https://github.com/capistrano/rbenv
#   https://github.com/capistrano/chruby
#   https://github.com/capistrano/bundler
#   https://github.com/capistrano/rails
#
# require "capistrano/rvm"
# require "capistrano/rbenv"
# require "capistrano/chruby"
# require "capistrano/bundler"
# require "capistrano/rails/assets"
# require "capistrano/rails/migrations"

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob("lib/capistrano/tasks/*.rake").each { |r| import r }

# Enable tracing at all times
Rake.application.options.trace = true
Rake.application.options.backtrace = true
