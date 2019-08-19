require 'rails_helper'

RSpec.describe "Rake::Task['tokens:remove_expired']", type: :task do
  Rails.application.load_tasks

  subject(:task) { Rake::Task['tokens:remove_expired'] }

  let!(:committee_member_token_1) { FactoryBot.create :committee_member_token, token_created_on: Date.today }
  let!(:committee_member_token_2) { FactoryBot.create :committee_member_token, token_created_on: (Date.today - 190.days) }

  before do
    task.reenable
  end

  xit 'removes expired committee member tokens' do
    expect(Rails.logger).to receive(:info).with('Removed 1 expired committee member token.')
    task.invoke
    expect(CommitteeMemberToken.find(committee_member_token_1.id)).to be_present
    expect { CommitteeMemberToken.find(committee_member_token_2.id) }.to raise_error ActiveRecord::RecordNotFound
  end
end