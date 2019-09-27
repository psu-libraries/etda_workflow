# frozen_string_literal: true

require 'whenever/capistrano'
# config valid for current version and patch releases of Capistrano
lock "~> 3.11.0"

set :application, "etda_workflow"
# set :partner, fetch(:partner, 'graduate')
set :repo_url, "git@github.com:/psu-stewardship/#{fetch(:application)}.git"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"
set :branch, ENV['REVISION'] || ENV['BRANCH_NAME'] || 'master'

set :user, 'deploy'
set :use_sudo, false

set :deploy_via, :remote_cache
set :tmp_dir, "/opt/deploy/#{fetch(:application)}_#{fetch(:partner)}/tmp"
set :copy_remote_dir, deploy_to

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure
set :ssh_options, {
  keys: [File.join(ENV['HOME'], '.ssh', 'id_deploy_rsa')],
  forward_agent: true
}

# rbenv settings
set :rbenv_type, :user # or :system, depends on your rbenv setup
set :rbenv_ruby, File.read(File.join(File.dirname(__FILE__), '..', '.ruby-version')).chomp # read from file above
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec" # rbenv settings
set :rbenv_map_bins, %w[rake gem bundle ruby rails] # map the following bins
set :rbenv_roles, :all # default value

# set passenger to just the web servers
set :passenger_roles, :web

# rails settings, NOTE: Task is wired into event stack
set :rails_env, 'production'
# Variable added after webpack/yarn started to fail on workflow prod/stage but not other hosts.  Worked for first partner on deploy but hung on others.  Once added everything worked.
set :default_env, { 'NODE_ENV' => 'production' }

# Settings for whenever gem that updates the crontab file on the server
# See schedule.rb for details
# set :whenever_environment, ->{ "#{fetch(:stage)}" }  this is being set to 'dev' so hardcoded production in schedule.rb
set :whenever_identifier, -> { "#{fetch(:application)}_#{fetch(:partner)}" }
set :whenever_roles, %i[audit app]

set :log_level, :debug
# set :pty, true

# Default value for :format is :airbrussh.
# set :format, :airbrussh
set :format_options, command_output: false

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", "config/secrets.yml"
#
#

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
set :keep_releases, 7

# SideKiq commands
namespace :sidekiq do
  %i[stop start].each do |action|
    desc "#{action.to_s.capitalize} SideKiq"
    task action do
      on roles(:app) do
        execute "sudo /bin/systemctl #{action} sidekiq_pool_#{fetch(:partner)}"
      end
    end
  end

  after "deploy:starting", "sidekiq:stop"
  after "deploy:published", "sidekiq:start"
end



# Apache namespace to control apache
namespace :apache do
  %i[stop start restart reload].each do |action|
    desc "#{action.to_s.capitalize} Apache"
    task action do
      on roles(:web) do
        execute "sudo /bin/systemctl #{action} httpd"
      end
    end
  end
end

set :linked_dirs, fetch(:linked_dirs, []).push(
  'log',
  'tmp/cache',
  'tmp/pids',
  'tmp/sockets',
  'uploads',
  'vendor/bundle',
  'public/packs',
  'node_modules'
)
# packs and modules added because of deployment issue.  Worked for first partner on deploy but hung on others.  Once added everything worked.

namespace :deploy do
  task :symlink_shared do
    desc 'set up the shared directory to have the symbolic links to the appropriate directories shared between servers'
    puts release_path.to_s
    on roles(:web) do
      execute "ln -sf /#{fetch(:application)}/config_#{fetch(:stage)}/#{fetch(:partner)}_devise.yml #{release_path}/config/devise.yml"
      execute "ln -sf /#{fetch(:application)}/config_#{fetch(:stage)}/#{fetch(:partner)}_database.yml #{release_path}/config/database.yml"
      execute "ln -sf /#{fetch(:application)}/config_#{fetch(:stage)}/lion_path.yml #{release_path}/config/lion_path.yml"
      execute "ln -sf /#{fetch(:application)}/config_#{fetch(:stage)}/#{fetch(:partner)}_secrets.yml #{release_path}/config/secrets.yml"
      execute "ln -sf /#{fetch(:application)}/config_#{fetch(:stage)}/ldap.yml #{release_path}/config/ldap.yml"
      execute "ln -sf /#{fetch(:application)}/config_#{fetch(:stage)}/sidekiq.yml #{release_path}/config/sidekiq.yml"
      execute "ln -sf /#{fetch(:application)}/config_#{fetch(:stage)}/redis.yml #{release_path}/config/redis.yml"
      execute "ln -sf /#{fetch(:application)}/config_#{fetch(:stage)}/newrelic.yml #{release_path}/config/newrelic.yml"
      execute "ln -sf /#{fetch(:application)}/config_#{fetch(:stage)}/admin_email_blacklist.yml #{release_path}/admin_email_blacklist.yml"
      execute "ln -sf /etda_workflow/data/#{fetch(:stage)}/etda_workflow_#{fetch(:partner)}/ #{release_path}/workflow_data_files"
      execute "ln -sf /etda_workflow/data/#{fetch(:stage)}/etda_explore_#{fetch(:partner)}/ #{release_path}/explore_data_files"
    end
  end




  before "deploy:assets:precompile", "deploy:symlink_shared"
  before "deploy:assets:precompile", "yarn:install"
  before "deploy:assets:precompile", "yarn:check"
  # before "deploy:migrate", "deploy:symlink_shared"

  after "deploy:updated", "deploy:migrate"

end


# Used to keep x-1 instances of ruby on a machine.  Ex +4 leaves 3 versions on a machine.  +3 leaves 2 versions
namespace :rbenv_custom_ruby_cleanup do
  desc 'Clean up old rbenv versions'
  task :purge_old_versions do
    on roles(:web) do
      execute 'ls -dt ~deploy/.rbenv/versions/*/ | tail -n +3 | xargs rm -rf'
    end
  end
  after 'deploy:finishing', 'rbenv_custom_ruby_cleanup:purge_old_versions'
end

namespace :yarn do
  desc 'yarn tasks to perform on the repository before a deployment'
  task :install do
    puts '***running yarn install'
    on roles (:web) do 
      execute "cd #{release_path} && yarn install --frozen-lockfile --production"
    end
  end

  desc 'check dependencies'
  task :check do
    on roles (:web) do 
      puts '***running yarn check'
      execute "cd #{release_path} && yarn check --integrity --frozen-lockfile --production"
      execute "cd #{release_path} && yarn check --verify-tree --frozen-lockfile --production"
      execute "cd #{release_path} && yarn check --frozen-lockfile --production"
    end
  end
end


namespace :deploy_all do
  task :deploy do
    on roles(:all) do
      files = Dir.glob("config/deploy/#{fetch(:stage)}.*.rb")
      files.each do |file|
        file = file.sub('config/deploy/', '').sub('.rb', '')
        info "Deploying #{file} to #{fetch(:stage)}"
        system("cap #{file} deploy")
        Rake::Task['deploy:assets:precompile'].reenable
      end
    end
  end
end

task deploy_all: 'deploy_all:deploy'
