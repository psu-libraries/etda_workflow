if defined?(RSpec)
  require 'rspec/core'
  require 'rspec/core/rake_task'

  if defined?(RuboCop)
    require 'rubocop/rake_task'

    desc 'Run style checker'
    RuboCop::RakeTask.new(:rubocop) do |task|
      task.requires << 'rubocop-rspec'
      task.fail_on_error = true
    end
  end

  desc 'run specs'
  task ci: :environment do
    ENV['PARTNER'] = 'graduate'
    Rake::Task['spec'].invoke
    # ::Rake.application['spec'].reenable
    # ENV['PARTNER'] = 'honors'
    # Rake::Task['spec'].invoke
    # ::Rake.application['spec'].reenable
    # ENV['PARTNER'] = 'milsch'
    # Rake::Task['spec'].invoke
  end
end

