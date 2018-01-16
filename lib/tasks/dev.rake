if defined?(RSpec)
  require 'rspec/core'
  require 'rspec/core/rake_task'
  require 'bundler/audit/task'

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
    Rake::Task['rubocop'].invoke
    puts 'PARTNER=GRADUATE'
    ENV['PARTNER'] = 'graduate'
    Rake::Task['assets:precompile'].invoke
    Rake::Task['spec'].invoke
    ::Rake.application['spec'].reenable
    puts 'PARTNER=HONORS'
    ENV['PARTNER'] = 'honors'
    Rake::Task['spec'].invoke
    ::Rake.application['spec'].reenable
    puts 'PARTNER=MILSCH'
    ENV['PARTNER'] = 'milsch'
    Rake::Task['spec'].invoke
    Rake::Task['bundle:audit'].invoke
  end

  desc 'bundle audit'
  Bundler::Audit::Task.new do |task|
    task default: 'bundle:audit'
  end
end

