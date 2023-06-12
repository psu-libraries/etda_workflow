require 'active_support/core_ext/array/grouping'

node_total=ENV.fetch('CIRCLE_NODE_TOTAL', 1).to_i
node_index=ENV.fetch('CIRCLE_NODE_INDEX', 0).to_i

tasks = [ 
  "bundle exec rubocop",
  "JS=true PARTNER=graduate COVERAGE=true bundle exec rspec --tag js",
  "COVERAGE=true PARTNER=graduate bundle exec rspec --tag ~js",
  "bundle exec rspec --tag sset",
  "bundle exec rspec --tag milsch",
  "bundle exec rspec --tag honors"
]

my_tasks = tasks.in_groups(node_total)[node_index]

my_tasks.each do |task|
  system('bundle exec rails db:create')
  system('bundle exec rails db:migrate')
  system(task)
end
