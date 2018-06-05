# frozen_string_literal: true
require 'rails_helper'

RSpec.describe "Rake::Task['application:git_version_number']", type: :task do
  before do
    Rails.application.load_tasks
  end

  subject(:task) { Rake::Task['application:git_version_number'] }

  before { task.reenable }
  it 'updates the version number' do
    expect { task.invoke }.to output(/spec\/fixtures\/version_number.rb updated with v.101-test/).to_stdout
    expect(File.exist?(VERSION_NUMBER_FILE)).to be_truthy
    version_number_read = File.read(VERSION_NUMBER_FILE)
    expect(version_number_read).to eq('v.101-test')
  end
end