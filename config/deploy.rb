# config valid for current version and patch releases of Capistrano
lock "~> 3.10.1"

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
# set :tmp_dir, "/opt/heracles/deploy/#{fetch(:application)}_#{fetch(:partner)}/tmp"
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
set :rbenv_map_bins, %w(rake gem bundle ruby rails) # map the following bins
set :rbenv_roles, :all # default value

# set passenger to just the web servers
set :passenger_roles, :web

# rails settings, NOTE: Task is wired into event stack
set :rails_env, 'production'

# Settings for whenever gem that updates the crontab file on the server
# See schedule.rb for details
set :whenever_roles, [:app, :job]

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

# Apache namespace to control apache
namespace :apache do
  [:stop, :start, :restart, :reload].each do |action|
    desc "#{action.to_s.capitalize} Apache"
    task action do
      on roles(:web) do
        execute "sudo service httpd #{action}"
      end
    end
  end
end

set :linked_dirs, fetch(:linked_dirs, []).push(
  'log',
  'tmp/cache',
  'tmp/pids',
  'tmp/sockets',
  'tmp/uploads',
  'vendor/bundle'
)

namespace :deploy do
  task :symlink_shared do
    desc 'set up the shared directory to have the symbolic links to the appropriate directories shared between servers'
    puts "#{release_path}"
    on roles(:web) do
      execute "ln -sf /#{fetch(:application)}/config_#{fetch(:stage)}/#{fetch(:partner)}_devise.yml #{release_path}/config/devise.yml"
      execute "ln -sf /#{fetch(:application)}/config_#{fetch(:stage)}/#{fetch(:partner)}_database.yml #{release_path}/config/database.yml"
      execute "ln -sf /#{fetch(:application)}/config_#{fetch(:stage)}/lion_path.yml #{release_path}/config/lion_path.yml"
      execute "ln -sf /#{fetch(:application)}/config_#{fetch(:stage)}/#{fetch(:partner)}_secrets.yml #{release_path}/config/secrets.yml"
      execute "ln -sf /#{fetch(:application)}/config_#{fetch(:stage)}/ldap.yml #{release_path}/config/ldap.yml"
    end
  end

  before "deploy:migrate", "deploy:symlink_shared"

  after "deploy:updated", "deploy:migrate"

  # after "rbenv:setup", "passenger:install"
  after "deploy:restart", "passenger:warmup"

  namespace :passenger do
    desc 'Passenger Version Config Update'
    task :config_update do
      on roles(:web) do
        execute 'mkdir --parents /opt/heracles/deploy/passenger'
        execute 'cd ~deploy && echo -n "PassengerRuby " > ~deploy/passenger/passenger-ruby-version.cap   && rbenv which ruby >> ~deploy/passenger/passenger-ruby-version.cap'
        execute 'v_passenger_ruby=$(cat ~deploy/passenger/passenger-ruby-version.cap) &&    cp --force /etc/httpd/conf.d/phusion-passenger-default-ruby.conf ~deploy/passenger/passenger-ruby-version.tmp &&    sed -i -e "s|.*PassengerRuby.*|${v_passenger_ruby}|" ~deploy/passenger/passenger-ruby-version.tmp'
        execute 'sudo /bin/mv ~deploy/passenger/passenger-ruby-version.tmp /etc/httpd/conf.d/phusion-passenger-default-ruby.conf'
        execute 'sudo /sbin/service httpd restart'
      end
    end
  end
  after :published, 'passenger:config_update'
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

namespace :deploy_all do
  task :deploy do
    on roles(:all) do
      files = Dir.glob("config/deploy/#{fetch(:stage)}.*.rb")
      files.each do |file|
        file = file.sub('config/deploy/', '').sub('.rb', '')
        info "Deploying #{file} to #{fetch(:stage)}"
        system("cap #{file} deploy")
      end
    end
  end
end

task deploy_all: 'deploy_all:deploy'
