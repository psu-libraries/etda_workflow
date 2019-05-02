# frozen_string_literal: true

require 'model_spec_helper'

RSpec.describe ApprovalStatus, type: :model do
  let(:submission) { FactoryBot.create :submission }
  let(:approval_configuration1) { ApprovalConfiguration.create(rejections_permitted: 0) }
  let(:approval_configuration2) { ApprovalConfiguration.create(rejections_permitted: 1) }

  describe "#status" do
    context "when 0 rejections are permitted" do
      before do
        submission.degree.degree_type.approval_configuration = approval_configuration1
      end

      context "when no committee members" do
        it "returns none" do
          expect(described_class.new(submission).status).to eq('none')
        end
      end

      context "when all committee members approve" do
        it "returns approved" do
          submission.committee_members << FactoryBot.create(:committee_member, submission: submission, status: 'approved', is_voting: true)
          submission.committee_members << FactoryBot.create(:committee_member, submission: submission, status: 'approved', is_voting: true)

          expect(described_class.new(submission).status).to eq('approved')
        end
      end

      context "when at least one committee member rejects" do
        it "returns rejected" do
          submission.committee_members << FactoryBot.create(:committee_member, submission: submission, status: 'rejected', is_voting: true)
          submission.committee_members << FactoryBot.create(:committee_member, submission: submission, status: 'approved', is_voting: true)

          expect(described_class.new(submission).status).to eq('rejected')
        end
      end

      context "when not all committee members have approved" do
        it "returns pending" do
          submission.committee_members << FactoryBot.create(:committee_member, submission: submission, status: 'pending', is_voting: true)
          submission.committee_members << FactoryBot.create(:committee_member, submission: submission, status: 'pending', is_voting: true)

          expect(described_class.new(submission).status).to eq('pending')
        end
      end

      context "when one committee member has no status and the other approves" do
        it "returns pending" do
          submission.committee_members << FactoryBot.create(:committee_member, submission: submission, status: nil, is_voting: true)
          submission.committee_members << FactoryBot.create(:committee_member, submission: submission, status: 'approved', is_voting: true)

          expect(described_class.new(submission).status).to eq('pending')
        end
      end

      context "when a committee member is non voting" do
        it 'does not affect submission approval status' do
          submission.committee_members << FactoryBot.create(:committee_member, submission: submission, status: nil, is_voting: false)
          submission.committee_members << FactoryBot.create(:committee_member, submission: submission, status: 'approved', is_voting: true)
          submission.committee_members << FactoryBot.create(:committee_member, submission: submission, status: 'approved', is_voting: true)

          expect(described_class.new(submission).status).to eq('approved')
        end
      end
    end

    context "when 1 rejection is permitted" do
      before do
        submission.degree.degree_type.approval_configuration = approval_configuration2
      end

      context "when one committee member rejects and the rest approve" do
        it "returns approved" do
          submission.committee_members << FactoryBot.create(:committee_member, submission: submission, status: 'rejected', is_voting: true)
          submission.committee_members << FactoryBot.create(:committee_member, submission: submission, status: 'approved', is_voting: true)
          submission.committee_members << FactoryBot.create(:committee_member, submission: submission, status: 'approved', is_voting: true)

          expect(described_class.new(submission).status).to eq('approved')
        end
      end

      context "when one committee member is pending and the rest approve" do
        it "returns approved" do
          submission.committee_members << FactoryBot.create(:committee_member, submission: submission, status: 'pending', is_voting: true)
          submission.committee_members << FactoryBot.create(:committee_member, submission: submission, status: 'approved', is_voting: true)
          submission.committee_members << FactoryBot.create(:committee_member, submission: submission, status: 'approved', is_voting: true)

          expect(described_class.new(submission).status).to eq('approved')
        end
      end

      context "when two commitee members reject and the rest approve" do
        it "returns rejected" do
          submission.committee_members << FactoryBot.create(:committee_member, submission: submission, status: 'rejected', is_voting: true)
          submission.committee_members << FactoryBot.create(:committee_member, submission: submission, status: 'rejected', is_voting: true)
          submission.committee_members << FactoryBot.create(:committee_member, submission: submission, status: 'approved', is_voting: true)

          expect(described_class.new(submission).status).to eq('rejected')
        end
      end

      context "when two commitee members reject, one is pending, and the rest approve" do
        it "returns rejected" do
          submission.committee_members << FactoryBot.create(:committee_member, submission: submission, status: 'pending', is_voting: true)
          submission.committee_members << FactoryBot.create(:committee_member, submission: submission, status: 'rejected', is_voting: true)
          submission.committee_members << FactoryBot.create(:committee_member, submission: submission, status: 'rejected', is_voting: true)
          submission.committee_members << FactoryBot.create(:committee_member, submission: submission, status: 'approved', is_voting: true)

          expect(described_class.new(submission).status).to eq('rejected')
        end
      end

      context "when one committee member rejects, but the rest are pending" do
        it "returns pending" do
          submission.committee_members << FactoryBot.create(:committee_member, submission: submission, status: 'pending', is_voting: true)
          submission.committee_members << FactoryBot.create(:committee_member, submission: submission, status: 'pending', is_voting: true)
          submission.committee_members << FactoryBot.create(:committee_member, submission: submission, status: 'pending', is_voting: true)
          submission.committee_members << FactoryBot.create(:committee_member, submission: submission, status: 'rejected', is_voting: true)

          expect(described_class.new(submission).status).to eq('pending')
        end
      end

      context "when one committee member has no status and the other approves" do
        it "returns approved" do
          submission.committee_members << FactoryBot.create(:committee_member, submission: submission, status: nil, is_voting: true)
          submission.committee_members << FactoryBot.create(:committee_member, submission: submission, status: 'approved', is_voting: true)

          expect(described_class.new(submission).status).to eq('approved')
        end
      end
    end
  end
end
