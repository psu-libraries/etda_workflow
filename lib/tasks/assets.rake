# frozen_string_literal: true

# /lib/tasks/assets.rake
Rake::Task["assets:precompile"].clear
namespace :assets do
  task 'precompile' do
    $stdout.puts '#----- Skip asset precompilation -----#'
    $stdout.puts '#----- Run webpack instead -----#'
    `yarn install --pure-lockfile`
    `webpack`
  end
end
