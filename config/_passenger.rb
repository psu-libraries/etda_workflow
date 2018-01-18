# frozen_string_literal: true

# Passenger Capistrano Task
# The passenger install task allows Chef to install Passenger now via Yum, but it allows Capistrano to maintain the file
# as Ruby is updated on the system.  The PassengerDefaultRuby variable is set to system ruby by default from the Yum
# install.  This will not work in our environment.
# Passenger Install Task below defines the current ruby version
# Adds it to temp file
# then copies passenger configs to temp file.
# Replaces all instances of PassengerRuby with proper version in temp file.
# Replace passenger conf file with temp file.

namespace :passenger do
  desc "Passenger Version Config Update"
  task :install, roles: :web do
    run <<-CMD.compact
  mkdir --parents /opt/heracles/deploy/passenger
  cd ~deploy &&
  echo -n "PassengerRuby " > ~deploy/passenger/passenger-ruby-version.cap && rbenv which ruby >> ~deploy/passenger/passenger-ruby-version.cap &&
  v_passenger_ruby=$(cat ~deploy/passenger/passenger-ruby-version.cap) &&
  cp --force /etc/httpd/conf.d/phusion-passenger-default-ruby.conf ~deploy/passenger/passenger-ruby-version.tmp &&
  sed -i -e "s|.*PassengerRuby.*|${v_passenger_ruby}|" ~deploy/passenger/passenger-ruby-version.tmp &&
  sudo /bin/mv ~deploy/passenger/passenger-ruby-version.tmp /etc/httpd/conf.d/phusion-passenger-default-ruby.conf &&
  sudo /sbin/service httpd restart
    CMD
    #    passenger.warmup
  end

  desc "warm up passenger"
  task :warmup, roles: :web do
    # run "curl -s -k -o /dev/null --head https://$(hostname -f)"
    run "echo"
  end
end
