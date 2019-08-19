# frozen_string_literal: true

require 'model_spec_helper'

RSpec.describe ApprovalStatus, type: :model do
  let(:degree) { FactoryBot.create :degree, degree_type: DegreeType.default }
  let(:submission) { FactoryBot.create :submission, degree: degree }
  let(:approval_configuration1) { ApprovalConfiguration.create(configuration_threshold: 0, use_percentage: 0, approval_deadline_on: Date.today, head_of_program_is_approving: false) }
  let(:approval_configuration2) { ApprovalConfiguration.create(configuration_threshold: 1, use_percentage: 0, approval_deadline_on: Date.today, head_of_program_is_approving: false) }
  let(:approval_configuration3) { ApprovalConfiguration.create(configuration_threshold: 100, use_percentage: 1, approval_deadline_on: Date.today, head_of_program_is_approving: false) }
  let(:approval_configuration4) { ApprovalConfiguration.create(configuration_threshold: 75, use_percentage: 1, approval_deadline_on: Date.today, head_of_program_is_approving: false) }

  describe "#status" do
    context "when using rejections permitted" do
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

    context "when using percentage for approval" do
      context "when percentage for approval is 100" do
        before do
          submission.degree.degree_type.approval_configuration = approval_configuration3
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

        context "when some committee members approve and some are pending" do
          it "returns pending" do
            submission.committee_members << FactoryBot.create(:committee_member, submission: submission, status: 'approved', is_voting: true)
            submission.committee_members << FactoryBot.create(:committee_member, submission: submission, status: 'approved', is_voting: true)
            submission.committee_members << FactoryBot.create(:committee_member, submission: submission, status: 'pending', is_voting: true)
            submission.committee_members << FactoryBot.create(:committee_member, submission: submission, status: 'pending', is_voting: true)

            expect(described_class.new(submission).status).to eq('pending')
          end
        end

        context "when at least one committee member rejects" do
          it "returns rejected" do
            submission.committee_members << FactoryBot.create(:committee_member, submission: submission, status: 'rejected', is_voting: true)
            submission.committee_members << FactoryBot.create(:committee_member, submission: submission, status: 'approved', is_voting: true)

            expect(described_class.new(submission).status).to eq('rejected')
          end
        end
      end

      context "when percentage for approval is 75" do
        before do
          submission.degree.degree_type.approval_configuration = approval_configuration4
        end

        context "when all committee members approve" do
          it "returns approved" do
            submission.committee_members << FactoryBot.create(:committee_member, submission: submission, status: 'approved', is_voting: true)
            submission.committee_members << FactoryBot.create(:committee_member, submission: submission, status: 'approved', is_voting: true)
            submission.committee_members << FactoryBot.create(:committee_member, submission: submission, status: 'approved', is_voting: true)
            submission.committee_members << FactoryBot.create(:committee_member, submission: submission, status: 'approved', is_voting: true)

            expect(described_class.new(submission).status).to eq('approved')
          end
        end

        context "when 75 percent approve" do
          it "returns approved" do
            submission.committee_members << FactoryBot.create(:committee_member, submission: submission, status: 'rejected', is_voting: true)
            submission.committee_members << FactoryBot.create(:committee_member, submission: submission, status: 'approved', is_voting: true)
            submission.committee_members << FactoryBot.create(:committee_member, submission: submission, status: 'approved', is_voting: true)
            submission.committee_members << FactoryBot.create(:committee_member, submission: submission, status: 'approved', is_voting: true)

            expect(described_class.new(submission).status).to eq('approved')
          end
        end

        context "when 50 percent reject" do
          it "returns rejected" do
            submission.committee_members << FactoryBot.create(:committee_member, submission: submission, status: 'rejected', is_voting: true)
            submission.committee_members << FactoryBot.create(:committee_member, submission: submission, status: 'rejected', is_voting: true)
            submission.committee_members << FactoryBot.create(:committee_member, submission: submission, status: 'approved', is_voting: true)
            submission.committee_members << FactoryBot.create(:committee_member, submission: submission, status: 'approved', is_voting: true)

            expect(described_class.new(submission).status).to eq('rejected')
          end
        end

        context "when 50 percent approve but only 25 percent reject (25 percent pending)" do
          it "returns pending" do
            submission.committee_members << FactoryBot.create(:committee_member, submission: submission, status: 'pending', is_voting: true)
            submission.committee_members << FactoryBot.create(:committee_member, submission: submission, status: 'rejected', is_voting: true)
            submission.committee_members << FactoryBot.create(:committee_member, submission: submission, status: 'approved', is_voting: true)
            submission.committee_members << FactoryBot.create(:committee_member, submission: submission, status: 'approved', is_voting: true)

            expect(described_class.new(submission).status).to eq('pending')
          end
        end
      end
    end
  end

  describe "#head_of_program_status" do
    before do
      head_role = CommitteeRole.find_by(name: 'Program Head/Chair', degree_type_id: submission.degree.degree_type_id)
      submission.committee_members = []
      FactoryBot.create(:committee_member, status: 'pending', committee_role_id: head_role.id, submission: submission) if current_partner.graduate?
    end

    it 'grabs status of Program Head/Chair' do
      skip 'Graduate Only' unless current_partner.graduate?

      expect(described_class.new(submission).head_of_program_status).to eq('pending')
    end
  end
end
