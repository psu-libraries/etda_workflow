require 'rails_helper'
require 'shoulda-matchers'

RSpec.describe FinalSubmissionPendingService do
  let(:service) { described_class.new(submission, params, 'adminflow') }
  let!(:submission) { FactoryBot.create :submission, :waiting_for_committee_review, degree: degree }
  let!(:degree) { FactoryBot.create :degree, degree_type: DegreeType.default }
  let!(:approval_config) { FactoryBot.create :approval_configuration, degree_type: DegreeType.default, head_of_program_is_approving: false }

  describe "#respond" do
    context 'when params[:update_metadata]' do
      let(:params) do
        ActionController::Parameters.new(update_metadata: "Update Metadata", submission: { title: 'New Title' })
      end

      context 'when committee has blank reviews' do
        it 'updates the metadata' do
          expect(service.respond).to eq(
            msg: "The submission was successfully updated.",
            redirect_to: "/admin/submissions/#{submission.id}/edit"
          )
          submission.reload
          expect(submission.title).to eq 'New Title'
          expect(submission.status).to eq 'waiting for committee review'
          expect(WorkflowMailer.deliveries.count).to eq 0
        end
      end

      context 'when committee has all approved reviews' do
        it 'moves the submission to final submission is submitted' do
          create_committee(submission)
          submission.committee_members.each { |cm| cm.update status: 'approved' }
          expect(service.respond).to eq(
            msg: "The submission was successfully updated.",
            redirect_to: "/admin/submissions/#{submission.id}/edit"
          )
          submission.reload
          expect(submission.title).to eq 'New Title'
          expect(submission.status).to eq 'waiting for final submission response'
          expect(WorkflowMailer.deliveries.count).to eq 1
        end
      end
    end

    context 'when params[:return_to_author]' do
      let(:params) do
        ActionController::Parameters.new(return_to_author: "Return to author", submission: { title: 'New Title' })
      end

      it 'updated metadata, moves the submission to "waiting for committee review rejected", and send email' do
        submission.committee_members << (FactoryBot.create :committee_member)
        expect(service.respond).to eq(
          msg: "The submission was successfully returned to the student for resubmission.",
          redirect_to: "/admin/submissions/#{submission.id}/edit"
        )
        submission.reload
        expect(submission.title).to eq 'New Title'
        expect(submission.status).to eq 'waiting for committee review rejected'
        expect(WorkflowMailer.deliveries.count).to eq 2
      end
    end
  end
end
