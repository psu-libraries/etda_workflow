require 'rails_helper'
require 'shoulda-matchers'

RSpec.describe "Test sending email with sidekiq" do
  Sidekiq::Logging.logger = nil

  let(:submission) { FactoryBot.create :submission }

  context "when approval process starts" do
    it 'sends email to sidekiq' do
      expect{ WorkflowMailer.committee_member_approval_started(submission.id, "test@psu.edu").deliver_later(wait_until: 5.days.from_now) }.to change{ Sidekiq::Worker.jobs.size }.by(1)
    end
  end
end