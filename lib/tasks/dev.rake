if defined?(RSpec)
  require 'rspec/core'
  require 'rspec/core/rake_task'

  desc 'run specs'
  task ci: [] do
    Rake::Task['spec'].invoke
#    ::Rake.application['spec'].reenable
  end


end
