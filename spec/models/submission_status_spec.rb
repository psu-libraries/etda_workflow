require 'rails_helper'
require 'shoulda-matchers'
require 'support/request_spec_helper'

RSpec.describe SubmissionStatus, type: :model do
  context '#initialize' do
    let(:submission) { FactoryBot.create :submission }
    it 'obtains the submission status' do
      expect(described_class.new(submission).current_status).to eq(submission.status)
      expect(described_class.new(submission).current_submission).to eq(submission)
    end
  end
  context '#WORKFLOW_STATUS' do
    it 'is an array' do
      expect(described_class::WORKFLOW_STATUS).to be_a_kind_of(Array)
      expect(described_class::WORKFLOW_STATUS).to include('collecting committee')
      expect(described_class::WORKFLOW_STATUS).to include('released for publication')
    end
  end
  it 'responds to #collecting_program_information?' do
    expect(described_class.new(Submission.new(status: 'collecting program information')).collecting_program_information?).to be_truthy
    expect(described_class.new(Submission.new(status: 'collecting program info')).collecting_program_information?).to be_falsey
  end
  it 'responds to #collecting_committee?' do
    expect(described_class.new(Submission.new(status: 'collecting committee')).collecting_committee?).to be_truthy
    expect(described_class.new(Submission.new(status: 'collecting committe')).collecting_committee?).to be_falsey
  end
  it 'responds to #collecting_format_review_files?' do
    expect(described_class.new(Submission.new(status: 'collecting format review files')).collecting_format_review_files?).to be_truthy
    expect(described_class.new(Submission.new(status: 'collecting format review files rejected')).collecting_format_review_files?).to be_truthy
    expect(described_class.new(Submission.new(status: 'collecting format review')).collecting_format_review_files?).to be_falsey
  end
  it 'responds to #collecting_format_review_files_rejected?' do
    expect(described_class.new(Submission.new(status: 'collecting format review files', format_review_rejected_at: DateTime.now)).collecting_format_review_files_rejected?).to be_truthy
    expect(described_class.new(Submission.new(status: 'collecting format review files rejected', format_review_rejected_at: DateTime.now)).collecting_format_review_files_rejected?).to be_truthy
    expect(described_class.new(Submission.new(status: 'collecting format review files', format_review_rejected_at: DateTime.now, format_review_approved_at: DateTime.now)).collecting_format_review_files_rejected?).to be_falsey
  end
  it 'responds to #waiting_for_format_review_response?' do
    expect(described_class.new(Submission.new(status: 'waiting for format review response')).waiting_for_format_review_response?).to be_truthy
    expect(described_class.new(Submission.new(status: 'waiting for format review respon')).waiting_for_format_review_response?).to be_falsey
  end
  it 'responds to #collecting_final_submission_files?' do
    expect(described_class.new(Submission.new(status: 'collecting final submission files')).collecting_final_submission_files?).to be_truthy
    expect(described_class.new(Submission.new(status: 'collecting final submission files rejected')).collecting_final_submission_files?).to be_truthy
    expect(described_class.new(Submission.new(status: 'format review accepted')).collecting_final_submission_files?).to be_truthy
    expect(described_class.new(Submission.new(status: 'collecting final submission format review rejected')).collecting_final_submission_files?).to be_falsey
  end
  it 'responds to #collecting_final_submission_files_rejected?' do
    expect(described_class.new(Submission.new(status: 'collecting final submission files')).collecting_final_submission_files_rejected?).to be_falsey
    expect(described_class.new(Submission.new(status: 'collecting final submission files', final_submission_rejected_at: DateTime.now)).collecting_final_submission_files_rejected?).to be_truthy
    expect(described_class.new(Submission.new(status: 'collecting final submission files rejected', final_submission_approved_at: DateTime.now)).collecting_final_submission_files_rejected?).to be_falsey
  end
  it 'responds to #waiting_for_final_submission_response?' do
    expect(described_class.new(Submission.new(status: 'waiting for final submission response')).waiting_for_final_submission_response?).to be_truthy
    expect(described_class.new(Submission.new(status: 'waiting for final submission respons')).waiting_for_final_submission_response?).to be_falsey
  end
  it 'responds to #waiting_for_publication_release?' do
    expect(described_class.new(Submission.new(status: 'waiting for publication release')).waiting_for_publication_release?).to be_truthy
    expect(described_class.new(Submission.new(status: 'waiting for publication releas')).waiting_for_publication_release?).to be_falsey
  end
  it 'responds to #released_for_publication?' do
    expect(described_class.new(Submission.new(status: 'released for publication')).released_for_publication?).to be_truthy
    expect(described_class.new(Submission.new(status: 'released for publication metadata only')).released_for_publication?).to be_truthy
  end
  it 'responds to #released_for_publication_metadata_only?' do
    expect(described_class.new(Submission.new(status: 'released for publication metadata only', access_level: 'restricted')).released_for_publication_metadata_only?).to be_truthy
    expect(described_class.new(Submission.new(status: 'released for publication metadata only', access_level: 'restricted_to_institution')).released_for_publication_metadata_only?).to be_falsey
  end
  it 'responds to #beyond_collecting_program_information?' do
    expect(described_class.new(Submission.new(status: 'released for publication')).beyond_collecting_program_information?).to be_truthy
    expect(described_class.new(Submission.new(status: '')).beyond_collecting_program_information?).to be_falsey
  end
  it 'responds to #beyond_collecting_committee?' do
    expect(described_class.new(Submission.new(status: 'released for publication')).beyond_collecting_committee?).to be_truthy
    expect(described_class.new(Submission.new(status: '')).beyond_collecting_committee?).to be_falsey
  end
  it 'responds to #beyond_collecting_format_review_files?' do
    expect(described_class.new(Submission.new(status: 'released for publication')).beyond_collecting_format_review_files?).to be_truthy
    expect(described_class.new(Submission.new(status: 'waiting for format review response')).beyond_collecting_format_review_files?).to be_truthy
    expect(described_class.new(Submission.new(status: '')).beyond_collecting_format_review_files?).to be_falsey
  end
  it 'responds to #beyond_waiting_for_format_review_response?' do
    expect(described_class.new(Submission.new(status: 'released for publication')).beyond_waiting_for_format_review_response?).to be_truthy
    expect(described_class.new(Submission.new(status: 'waiting for format review response')).beyond_waiting_for_format_review_response?).to be_falsey
    expect(described_class.new(Submission.new(status: '')).beyond_waiting_for_format_review_response?).to be_falsey
  end
  it 'responds to #beyond_collecting_final_submission_files?' do
    expect(described_class.new(Submission.new(status: 'released for publication')).beyond_collecting_final_submission_files?).to be_truthy
    expect(described_class.new(Submission.new(status: 'waiting for final submission response')).beyond_collecting_final_submission_files?).to be_truthy
    expect(described_class.new(Submission.new(status: '')).beyond_waiting_for_format_review_response?).to be_falsey
  end
  it 'responds to #beyond_waiting_for_final_submission_response?' do
    expect(described_class.new(Submission.new(status: 'waiting for publication release')).beyond_waiting_for_final_submission_response?).to be_truthy
    expect(described_class.new(Submission.new(status: 'released for publication metadata only')).beyond_waiting_for_final_submission_response?).to be_truthy
    expect(described_class.new(Submission.new(status: '')).beyond_waiting_for_final_submission_response?).to be_falsey
  end
  describe 'submission#current_status' do
    let(:submission) { Submission.new }
    it 'responds to all methods' do
      expect(submission.current_status.collecting_program_information?).to be_truthy
      submission.status = 'collecting committee'
      expect(submission.current_status.collecting_committee?).to be_truthy
      expect(submission.current_status.beyond_collecting_program_information?).to be_truthy
      submission.status = 'collecting format review files'
      expect(submission.current_status.collecting_format_review_files?).to be_truthy
      expect(submission.current_status.beyond_collecting_format_review_files?).to be_falsey
    end
  end
end
