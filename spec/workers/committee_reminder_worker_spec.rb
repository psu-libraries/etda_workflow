require 'rails_helper'
require 'shoulda-matchers'

RSpec.describe CommitteeReminderWorker do
  Sidekiq::Logging.logger = nil

  let(:submission) { FactoryBot.create :submission }

  context "when approval process starts" do
    it 'queues to sidekiq via worker' do
      expect { described_class.perform_in(5.days, [submission.id, "test@psu.edu"]) }.to change { Sidekiq::Worker.jobs.size }.by(1)
    end

    it 'performs task' do
      Sidekiq::Testing.inline! do
        expect{ described_class.perform_async(submission.id, "test@psu.edu") }.to change { WorkflowMailer.deliveries.size }.by(1)
      end
    end
  end

  context "when submission no longer exists" do
    it 'NoMethodError is returned' do
      Sidekiq::Testing.inline! do
        expect { described_class.perform_async(submission.id + 1, "test@psu.edu") }.to raise_error(NoMethodError)
      end
    end
  end
end
