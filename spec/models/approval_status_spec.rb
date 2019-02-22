# frozen_string_literal: true

require 'model_spec_helper'

RSpec.describe ApprovalStatus, type: :model do
  let(:submission) { FactoryBot.create :submission }

  describe "#status" do
    context "when no committee members" do
      it "returns none" do
        expect(described_class.new(submission).status).to eq('none')
      end
    end
    context "when all committee members approve" do
      let(:committee_member1) { FactoryBot.create :committee_member, submission: submission, approved_at: Time.zone.now, approval_started_at: Time.zone.now }
      let(:committee_member2) { FactoryBot.create :committee_member, submission: submission, approved_at: Time.zone.now, approval_started_at: Time.zone.now }

      it "returns approved" do
        expect(committee_member1.status).to eq('approved')
        expect(described_class.new(submission).status).to eq('approved')
      end
    end
    context "when at least one committee member rejects" do
      it "returns rejected" do

        expect(described_class.new(submission).status).to eq('rejected')
      end
    end
    context "when not all committee members have approved" do
      it "returns pending" do

        expect(described_class.new(submission).status).to eq('pending')
      end
    end
  end
end