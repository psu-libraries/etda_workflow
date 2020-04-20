#frozen_string_literal: true

# This test and import test cannot run with other tests unless they're run at the end of all others.
# When the legacy database loads, it breaks subsequent tests.

require 'rails_helper'
require 'shoulda-matchers'
require 'active_record/fixtures'
require 'mysql2'

RSpec.describe "Rake::Task['db_update:dups']", :import_test, type: :task do
  before do
    Rails.application.load_tasks
    ActiveRecord::Tasks::DatabaseTasks.drop current_config
    ActiveRecord::Tasks::DatabaseTasks.create current_config
    ActiveRecord::Tasks::DatabaseTasks.database_configuration = current_config
    ActiveRecord::Tasks::DatabaseTasks.structure_load(current_config, Rails.root.join('spec', 'fixtures', 'legacy', 'dups', 'authors.sql'))
    ActiveRecord::Tasks::DatabaseTasks.structure_load(current_config, Rails.root.join('spec', 'fixtures', 'legacy', 'dups', 'submissions.sql'))
    ActiveRecord::Tasks::DatabaseTasks.structure_load(current_config, Rails.root.join('spec', 'fixtures', 'legacy', 'inbound_lion_path_records.sql'))
  end

  it 'lists authors, performs a dry run, and removes duplicate authors' do
    expected_result = "Access_id: ggg555, Id: 1, Submission Count: 1\nAccess_id: ggg555, Id: 2, Submission Count: 0\nAccess_id: hhh111, Id: 3, Submission Count: 0\nAccess_id: hhh111, Id: 4, Submission Count: 0\n"
    expect{Rake::Task['db_update:dups:list_authors'].invoke('legacy')}.to output(expected_result).to_stdout

    expected_result = "Dry Run (delete) - ggg555 2\nDry Run (delete) - hhh111 4\nTotal authors deleted: 2\n"
    Rake::Task['db_update:dups:fix_authors'].reenable
    expect{Rake::Task['db_update:dups:fix_authors'].invoke('legacy', 'dry_run')}.to output(expected_result).to_stdout

    original_count = Author.all.count
    Rake::Task['db_update:dups:fix_authors'].reenable
    Rake::Task['db_update:dups:fix_authors'].invoke('legacy')
    finish_count = Author.all.count
    expect(finish_count).to eq(original_count-2)
    expect(Author.where(access_id: 'ggg555').count).to eq(1)
    expect(Author.where(access_id: 'hhh111').count).to eq(1)
  end

  def current_config
    Rails.configuration.database_configuration['test_legacy_database']
  end
end