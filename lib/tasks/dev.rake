# frozen_string_literal: true

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

  desc 'run coverage'
  task check_coverage: :environment do
    ENV['PARTNER'] = 'graduate'
    task test_coverage: [:'legacy:db:test_fixtures:load', :spec]
    Rake::Task[:test_coverage].invoke
  end

  desc 'run specs'
  task ci: :environment do
    Rake::Task['rubocop'].invoke
    Rake::Task['assets:precompile'].invoke
    puts 'PARTNER=GRADUATE'
    ENV['PARTNER'] = 'graduate'
    Rake::Task['legacy:db:test_fixtures:load'].invoke
    ::Rake.application['spec'].reenable
    Rake::Task['spec'].invoke
    ::Rake.application['spec'].reenable
    puts 'PARTNER=HONORS'
    ENV['PARTNER'] = 'honors'
    Rake::Task['spec'].invoke
    ::Rake.application['spec'].reenable
    puts 'PARTNER=MILSCH'
    ENV['PARTNER'] = 'milsch'
    Rake::Task['spec'].invoke
    # Rake::Task['bundle:audit'].invoke
  end

  desc 'drone prepare'
  task drone_prepare: :environment do
    Rake::Task['db:create'].invoke
    Rake::Task['db:test:load'].invoke
    Rake::Task['db:migrate'].invoke
    Rake::Task['legacy:db:test_fixtures:load'].invoke
  end



  # desc 'bundle audit'
  # Bundler::Audit::Task.new do |task|
  #   task default: 'bundle:audit'
  # end
end
