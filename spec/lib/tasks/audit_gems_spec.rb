# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Rake::Task['audit:gems']", type: :task do
  Rails.application.load_tasks

  subject(:task) { Rake::Task['audit:gems'] }

  before { task.reenable }

  it 'checks whether there is an audit alert' do
    expect { task.invoke }.to output(/No vulnerabilities found/).to_stdout
  end

end