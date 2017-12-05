# Understanding Capistrano Processing Workflow
# http://capistranorb.com/documentation/getting-started/flow/
# Example Usage:
# First time:
# cap -S vstage=prod -s branch=master -s partner=honors prod-honors rbenv:setup deploy
# cap -S vstage=prod -s branch=master -s partner=graduate prod-graduate rbenv:setup deploy
# Subsequent Deploys
# cap -S vstage=prod -s branch=master -s partner=graduate prod-graduate  deploy
# cap -S vstage=prod -s branch=master -s partner=honors prod-honors deploy

require 'bundler/capistrano'
require 'capistrano-rbenv'
require 'capistrano/ext/multistage'
require 'capistrano-notification'

# Namespace environments so crontabs don't overwrite each other.
# set :whenever_identifier, defer { "#{application}_#{partner}" }
# set :whenever_command, "bundle exec whenever --update-crontab"
# require 'whenever/capistrano'

set :application, "etda_workflow"
# set :stage, fetch(:partner, 'qa')
set :partner, fetch(:partner, 'nopartnerspecified')
# set :stage
set :scm, :git
set :deploy_via, :remote_cache
set :repository,  "git@github.com:/psu-stewardship/#{application}.git"

# set :deploy_to, "/opt/heracles/deploy/#{application}"
set :user, "deploy"
set :use_sudo, false
default_run_options[:pty] = true
ssh_options[:forward_agent] = true
deploy_key = File.join(ENV["HOME"], ".ssh", "id_deploy_rsa")
if File.exist?(deploy_key)
  ssh_options[:keys] = [deploy_key]
else
  puts "Warning: You appear to be missing your ~/.ssh/id_deploy_rsa key. See the README for setup instructions."
end

set :rbenv_ruby_version, File.read(File.join(File.dirname(__FILE__), '..', '.ruby-version')).chomp
set :rbenv_setup_shell, false

# These are run manually, not as part of a deployment.
namespace :apache do
  [:stop, :start, :restart, :reload].each do |action|
    desc "#{action.to_s.capitalize} Apache"
    task action, roles: :web do
      invoke_command "sudo service httpd #{action}", via: run_method
    end
  end
end

# override default restart task for apache passenger
namespace :deploy do
  task :start do; end
  task :stop do; end
  task :restart, roles: :app, except: { no_release: true } do
    run "sudo /sbin/service httpd restart"
  end
end

# insert new task to symlink shared files
namespace :deploy do
  desc "Link shared files"
  task :symlink_shared do
    run <<-CMD.compact
    ln -sf /#{application}/config_#{stage}/#{partner}_devise.yml #{release_path}/config/devise.yml &&
    ln -sf /#{application}/config_#{stage}/#{partner}_database.yml #{release_path}/config/database.yml &&
    ln -sf /#{application}/config_#{stage}/lion_path.yml #{release_path}/config/lion_path.yml &&
    ln -sf /#{application}/config_#{stage}/ldap.yml #{release_path}/config/ldap.yml &&
    ln -sf /#{application}/config_#{stage}/#{partner}_secrets.yml #{release_path}/config/secrets.yml
    CMD
  end
end
# belongs in the block above when configuration is ready AND must ad && after last line
# ln -sf /var/data/#{application}-#{partner} #{release_path}/uploads

before "deploy:finalize_update", "deploy:symlink_shared"

# Always run migrations.
after "deploy:update_code", "deploy:migrate"

# Will bring back later not needed for prototype.
# Resolrize.
# namespace :deploy do
#  desc "Re-solrize objects"
#  task :resolrize, roles: :solr do
#    run <<-CMD.compact
#    cd -- #{latest_release} &&
#    RAILS_ENV=#{rails_env.to_s.shellescape} #{rake} #{application}:resolrize
#    CMD
#  end
# end
# after "deploy:migrate", "deploy:resolrize"

# config/deploy/_passenger.rb hooks.
after "rbenv:setup", "passenger:install"
after "deploy:restart", "passenger:warmup"

# Keep the last X number of releases.
set :keep_releases, 7
after "passenger:warmup", "deploy:cleanup"

# Restart resque-pool.
# desc "Restart resque-pool"
# task :resquepoolrestart do
#   on roles(:web) do
#     execute :sudo, "/sbin/service resque_pool restart"
#   end
# end
# before :restart, :resquepoolrestart

# Used to keep x-1 instances of ruby on a machine.  Ex +4 leaves 3 versions on a machine.  +3 leaves 2 versions
namespace :rbenv_custom_ruby_cleanup do
  desc "Clean up old rbenv versions"
  task :purge_old_versions do
    on roles(:web) do
      execute 'ls -dt ~deploy/.rbenv/versions/*/ | tail -n +3 | xargs rm -rf'
    end
  end
  after "deploy:finishing", "rbenv_custom_ruby_cleanup:purge_old_versions"
end

# Don't initialize rbenv if we're running in one of the fake "wrapper"
# deployment environments -- it won't work because it demands that an actual
# server be present.
namespace :rbenv do
  task(:setup_default_environment, except: { no_release: true }) do
    unless %w( dev staging qa prod ).include?(stage) # our addition
      if rbenv_setup_default_environment
        set(:default_environment, _merge_environment(default_environment, rbenv_environment))
      end
    end
  end
end

namespace :deploy do
  # Make a duplicate of the default :deploy task, because we're about to
  # overwrite it with a parallelized version.
  task :one do
    update
    restart
  end

  # Overwrite the default "deploy" task with a task that deploys to both
  # partners for the requested stage, in parallel.
  task :default, on_no_matching_servers: :continue do
    %w( graduate honors milsch ).map do |partner|
      Thread.new do
        sha = fetch :branch, 'master'
        cmd = "bundle exec cap -S vstage=#{stage} -s branch=#{sha} -s partner=#{partner} #{stage}-#{partner} deploy:one"
        puts cmd
        system cmd
      end
    end.each(&:join)
  end
end
