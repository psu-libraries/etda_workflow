# frozen_string_literal: true

# /lib/tasks/assets.rake
Rake::Task["assets:precompile"].clear
namespace :assets do
  task 'precompile' do
    puts '#----- Skip asset precompilation -----#'
    puts '#----- Run webpack instead -----#'
    `yarn install`
    `bin/webpack`
  end
end
