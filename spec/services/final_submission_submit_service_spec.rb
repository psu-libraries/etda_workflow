require 'rails_helper'
require 'shoulda-matchers'

RSpec.describe FinalSubmissionSubmitService do
  let!(:submission) { FactoryBot.create :submission, degree: degree }
  let!(:status_giver) { SubmissionStatusGiver.new(submission) }
  let!(:degree) { FactoryBot.create :degree, degree_type: DegreeType.default }

  let!(:approval_configuration) do
    FactoryBot.create(:approval_configuration, head_of_program_is_approving: false, degree_type: degree.degree_type)
  end

  before do
    SeventhDayEvaluationWorker.clear
    create_committee(submission)
  end

  context 'when submission is submitted after admin rejection' do
    it 'proceeds to the "waiting for final submission response" stage' do
      submission.update status: 'collecting final submission files rejected'
      service = described_class.new(submission, status_giver, {})
      service.submit_final_submission
      expect(Submission.find(submission.id).status).to eq 'waiting for final submission response'
      expect(WorkflowMailer.deliveries.count).to eq 1
    end
  end

  describe "#submit_final_submission" do
    context "when author submits final submission for the first time" do
      context 'when current_partner is non-graduate', honors: true, milsch: true, sset: true do
        it "proceeds submission to waiting for committee review" do
          skip 'Non-graduate only' if current_partner.graduate?

          submission.status = 'collecting final submission files'
          final_submission_params = {}
          described_class.new(submission, status_giver, final_submission_params).submit_final_submission
          expect(Submission.find(submission.id).status).to eq 'waiting for committee review'
          expect(SeventhDayEvaluationWorker.jobs.size).to eq 1
        end
      end

      context 'when current_partner is graduate' do
        context 'when advisor is not present' do
          it "proceeds submission to waiting for committee review" do
            submission.advisor.destroy!
            submission.reload
            submission.status = 'collecting final submission files'
            final_submission_params = {}
            described_class.new(submission, status_giver, final_submission_params).submit_final_submission
            expect(Submission.find(submission.id).status).to eq 'waiting for committee review'
            expect(SeventhDayEvaluationWorker.jobs.size).to eq 1
          end
        end

        context 'when advisor is present' do
          it "proceeds submission to waiting for advisor review" do
            submission.status = 'collecting final submission files'
            final_submission_params = {}
            described_class.new(submission, status_giver, final_submission_params).submit_final_submission
            expect(Submission.find(submission.id).status).to eq 'waiting for advisor review'
            expect(submission.advisor.approval_started_at).to be_truthy
            expect(SeventhDayEvaluationWorker.jobs.size).to eq 0
          end
        end
      end
    end

    context "when author submits final submission after committee rejects" do
      before do
        submission.committee_members.each do |cm|
          cm.update status: 'rejected'
        end
        submission.reload
      end

      context 'when current_partner is non-graduate', honors: true, milsch: true, sset: true do
        it "proceeds submission to waiting for committee review and resets committee statuses" do
          skip 'Non-graduate only' if current_partner.graduate?

          submission.status = 'waiting for committee review rejected'
          final_submission_params = {}
          described_class.new(submission, status_giver, final_submission_params).submit_final_submission
          expect(Submission.find(submission.id).status).to eq 'waiting for committee review'
          expect(submission.committee_members.pluck(:status)).to eq Array.new(submission.committee_members.count, '')
          expect(SeventhDayEvaluationWorker.jobs.size).to eq 1
        end
      end

      context 'when current_partner is graduate' do
        context 'when advisor is not present' do
          it "proceeds submission to waiting for committee review and resets committee statuses" do
            submission.advisor.destroy!
            submission.reload
            submission.status = 'waiting for committee review rejected'
            final_submission_params = {}
            described_class.new(submission, status_giver, final_submission_params).submit_final_submission
            expect(Submission.find(submission.id).status).to eq 'waiting for committee review'
            expect(submission.committee_members.pluck(:status)).to eq Array.new(5, '')
            expect(SeventhDayEvaluationWorker.jobs.size).to eq 1
          end
        end

        context 'when advisor is present' do
          it "proceeds submission to waiting for advisor review and resets committee statuses" do
            submission.status = 'waiting for committee review rejected'
            final_submission_params = {}
            described_class.new(submission, status_giver, final_submission_params).submit_final_submission
            expect(Submission.find(submission.id).status).to eq 'waiting for advisor review'
            expect(submission.committee_members.pluck(:status)).to eq Array.new(6, '')
            expect(SeventhDayEvaluationWorker.jobs.size).to eq 0
          end
        end
      end
    end
  end
end
