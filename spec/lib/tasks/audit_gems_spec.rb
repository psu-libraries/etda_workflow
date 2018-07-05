# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Rake::Task['audit:gems']", type: :task do
  Rails.application.load_tasks

  subject(:task) { Rake::Task['audit:gems'] }

  before { task.reenable }
  # prevent this from breaking build after partner has completed; audit gem runs once after everything's been built lib/tasks/dev.rake
  xit 'checks whether there is an audit alert' do
    expect { task.invoke }.to output(/No vulnerabilities found/).to_stdout
  end

end