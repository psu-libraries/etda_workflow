require 'rails_helper'
require 'shoulda-matchers'

RSpec.describe CommitteeReminderWorker do
  Sidekiq::Logging.logger = nil

  let(:submission) { FactoryBot.create :submission }

  context "when approval process starts" do
    it 'sends email to sidekiq via worker' do
      expect { described_class.perform_in(5.days, [submission.id, "test@psu.edu"]) }.to change { Sidekiq::Worker.jobs.size }.by(1)
    end
  end
end
