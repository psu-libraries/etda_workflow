# /lib/tasks/assets.rake
Rake::Task["assets:precompile"].clear
namespace :assets do
  task 'precompile' do
    puts '#----- Skip asset precompilation -----#'
    puts '#----- Run webpack instead -----#'
    %x(yarn install)
    %x(bin/webpack)
  end
end