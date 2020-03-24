require 'rails_helper'
require 'shoulda-matchers'

RSpec.describe CommitteeReminderWorker do
  let(:submission) { FactoryBot.create :submission }
  let(:committee_member) { FactoryBot.create :committee_member, submission: submission }
  let(:detached_member) { FactoryBot.create :committee_member }

  context "when approval process starts" do
    it 'queues to sidekiq via worker' do
      expect { described_class.perform_in(5.days, submission.id, committee_member.id) }.to change { Sidekiq::Worker.jobs.size }.by(1)
    end

    it 'performs task' do
      Sidekiq::Testing.inline! do
        expect { described_class.perform_async(submission.id, committee_member.id) }.to change { WorkflowMailer.deliveries.size }.by(1)
      end
    end
  end

  context "when submission no longer exists" do
    it 'NoMethodError is returned' do
      Sidekiq::Testing.inline! do
        expect { described_class.perform_async(submission.id + 1, committee_member.id) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  context "when committee member already accepted or rejected" do
    it 'does not deliver an email' do
      committee_member.update_attribute :status, 'approved'
      Sidekiq::Testing.inline! do
        expect { described_class.perform_async(submission.id, committee_member.id) }.to change { WorkflowMailer.deliveries.size }.by(0)
      end
    end
  end

  context "when submission does not match committee member" do
    it 'does not deliver an email' do
      Sidekiq::Testing.inline! do
        expect { described_class.perform_async(submission.id, detached_member.id) }.to change { WorkflowMailer.deliveries.size }.by(0)
      end
    end
  end
end
