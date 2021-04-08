require 'rails_helper'
require 'shoulda-matchers'

RSpec.describe FinalSubmissionPendingService do
  let(:service) { described_class.new(submission, params, 'adminflow')}
  let!(:submission) { FactoryBot.create :submission, :waiting_for_committee_review, degree: degree }
  let!(:degree) { FactoryBot.create :degree, degree_type: DegreeType.default }

  describe "#respond" do
    context 'when params[:update_metadata]' do
      let(:params) do
        ActionController::Parameters.new(update_metadata: "Update Metadata", submission: {title: 'New Title' })
      end

      it 'just updates the metadata' do
        expect(service.respond).to eq(
                                       {
                                         msg: "The submission was successfully updated.",
                                         redirect_to: "/admin/submissions/#{submission.id}/edit"
                                       }
                                     )
        submission.reload
        expect(submission.title).to eq 'New Title'
        expect(WorkflowMailer.deliveries.count).to eq 0
      end
    end

    context 'when params[:return_to_author]' do
      let(:params) do
        ActionController::Parameters.new(return_to_author: "Return to author", submission: {title: 'New Title' })
      end

      it 'updated metadata, moves the submission to "committee review rejected", and send email' do
        expect(service.respond).to eq(
                                       {
                                           msg: "The submission was successfully returned to the student for resubmission.",
                                           redirect_to: "/admin/submissions/#{submission.id}/edit"
                                       }
                                   )
        submission.reload
        expect(submission.title).to eq 'New Title'
        expect(submission.status).to eq 'committee review rejected'
        expect(WorkflowMailer.deliveries.count).to eq 1
      end
    end
  end
end
