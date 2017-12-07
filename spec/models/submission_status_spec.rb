require 'rails_helper'
require 'shoulda-matchers'

RSpec.describe SubmissionStatus, type: :model do
  context '#initialize' do
    let(:submission) { FactoryBot.create :submission }
    it 'obtains the submission status behavior' do
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

  let(:submission) { FactoryBot.create :submission }

  it 'responds to #collecting_program_information?' do
    submission.status = 'collecting program information'
    expect(described_class.new(submission).collecting_program_information?).to be_truthy
    submission.status = 'collecting program '
    expect(described_class.new(submission).collecting_program_information?).to be_falsey
  end
  it 'responds to #collecting_committee?' do
    submission.status = 'collecting committee'
    expect(described_class.new(submission).collecting_committee?).to be_truthy
    submission.status = 'collecting commm'
    expect(described_class.new(submission).collecting_committee?).to be_falsey
  end
  it 'responds to #collecting_format_review_files?' do
    submission.status = 'collecting format review files'
    expect(described_class.new(submission).collecting_format_review_files?).to be_truthy
    submission.status = 'collecting format review files rejected'
    expect(described_class.new(submission).collecting_format_review_files?).to be_truthy
    submission.status = 'collecting format review'
    expect(described_class.new(submission).collecting_format_review_files?).to be_falsey
  end
  it 'responds to #collecting_format_review_files_rejected?' do
    submission.status = 'collecting format review files'
    submission.format_review_rejected_at = DateTime.now
    expect(described_class.new(submission).collecting_format_review_files_rejected?).to be_truthy
    submission.status = 'collecting format review files rejected'
    submission.format_review_rejected_at = DateTime.now
    expect(described_class.new(submission).collecting_format_review_files_rejected?).to be_truthy
    submission.status = 'collecting format review files'
    submission.format_review_rejected_at = DateTime.now
    submission.format_review_approved_at = DateTime.now
    expect(described_class.new(submission).collecting_format_review_files_rejected?).to be_falsey
  end
  it 'responds to #waiting_for_format_review_response?' do
    submission.status = 'waiting for format review response'
    expect(described_class.new(submission).waiting_for_format_review_response?).to be_truthy
    submission.status = 'waiting for format review respon'
    expect(described_class.new(submission).waiting_for_format_review_response?).to be_falsey
  end
  it 'responds to #collecting_final_submission_files?' do
    submission.status = 'collecting final submission files'
    expect(described_class.new(submission).collecting_final_submission_files?).to be_truthy
    submission.status = 'collecting final submission files rejected'
    expect(described_class.new(submission).collecting_final_submission_files?).to be_truthy
    submission.status = 'format review accepted'
    expect(described_class.new(submission).collecting_final_submission_files?).to be_truthy
    submission.status = 'collecting final submission format review rejected'
    expect(described_class.new(submission).collecting_final_submission_files?).to be_falsey
  end
  it 'responds to #collecting_final_submission_files_rejected?' do
    submission.status = 'collecting final submission files'
    expect(described_class.new(submission).collecting_final_submission_files_rejected?).to be_falsey
    submission.status = 'collecting final submission files'
    submission.final_submission_rejected_at = DateTime.now
    expect(described_class.new(submission).collecting_final_submission_files_rejected?).to be_truthy
    submission.status = 'collecting final submission files rejected'
    submission.final_submission_approved_at = DateTime.now
    expect(described_class.new(submission).collecting_final_submission_files_rejected?).to be_falsey
  end
  it 'responds to #waiting_for_final_submission_response?' do
    submission.status = 'waiting for final submission response'
    expect(described_class.new(submission).waiting_for_final_submission_response?).to be_truthy
    submission.status = 'waiting for final submission resp'
    expect(described_class.new(submission).waiting_for_final_submission_response?).to be_falsey
  end
  it 'responds to #waiting_for_publication_release?' do
    submission.status = 'waiting for publication release'
    expect(described_class.new(submission).waiting_for_publication_release?).to be_truthy
    submission.status = 'waiting for publication'
    expect(described_class.new(submission).waiting_for_publication_release?).to be_falsey
  end
  it 'responds to #released_for_publication?' do
    submission.status = 'released for publication'
    expect(described_class.new(submission).released_for_publication?).to be_truthy
    submission.status = 'released for publication metadata only'
    expect(described_class.new(submission).released_for_publication?).to be_truthy
  end
  it 'responds to #released_for_publication_metadata_only?' do
    submission.status = 'released for publication metadata only'
    submission.access_level = 'restricted'
    expect(described_class.new(submission).released_for_publication_metadata_only?).to be_truthy
    submission.access_level = 'restricted_to_institution'
    expect(described_class.new(submission).released_for_publication_metadata_only?).to be_falsey
  end
  it 'responds to #beyond_collecting_program_information?' do
    submission.status = 'released for publication'
    expect(described_class.new(submission).beyond_collecting_program_information?).to be_truthy
    submission.status = ''
    expect(described_class.new(submission).beyond_collecting_program_information?).to be_falsey
  end
  it 'responds to #beyond_collecting_committee?' do
    submission.status = 'released for publication'
    expect(described_class.new(submission).beyond_collecting_committee?).to be_truthy
    submission.status = ''
    expect(described_class.new(submission).beyond_collecting_committee?).to be_falsey
  end
  it 'responds to #beyond_collecting_format_review_files?' do
    submission.status = 'released for publication'
    expect(described_class.new(submission).beyond_collecting_format_review_files?).to be_truthy
    submission.status = 'waiting for format review response'
    expect(described_class.new(submission).beyond_collecting_format_review_files?).to be_truthy
    submission.status = ''
    expect(described_class.new(submission).beyond_collecting_format_review_files?).to be_falsey
  end
  it 'responds to #beyond_waiting_for_format_review_response?' do
    submission.status = 'released for publication'
    expect(described_class.new(submission).beyond_waiting_for_format_review_response?).to be_truthy
    submission.status = 'waiting for format review response'
    expect(described_class.new(submission).beyond_waiting_for_format_review_response?).to be_falsey
    submission.status = ''
    expect(described_class.new(submission).beyond_waiting_for_format_review_response?).to be_falsey
  end
  it 'responds to #beyond_collecting_final_submission_files?' do
    submission.status = 'released for publication'
    expect(described_class.new(submission).beyond_collecting_final_submission_files?).to be_truthy
    submission.status = 'waiting for final submission response'
    expect(described_class.new(submission).beyond_collecting_final_submission_files?).to be_truthy
    submission.status = ''
    expect(described_class.new(submission).beyond_waiting_for_format_review_response?).to be_falsey
  end
  it 'responds to #beyond_waiting_for_final_submission_response?' do
    submission.status = 'waiting for publication release'
    expect(described_class.new(submission).beyond_waiting_for_final_submission_response?).to be_truthy
    submission.status = 'released for publication metadata only'
    expect(described_class.new(submission).beyond_waiting_for_final_submission_response?).to be_truthy
    submission.status = ''
    expect(described_class.new(submission).beyond_waiting_for_final_submission_response?).to be_falsey
  end
  it 'responds to embargoed?' do
    submission.status = 'confidential hold embargo'
    expect(described_class.new(submission).embargoed?).to be_truthy
  end

  it 'responds to final_confidential_hold?' do
    author = FactoryBot.create :author, :confidential_hold
    submission.status = 'waiting for final submission response'
    submission.author_id = author.id
    expect(described_class.new(submission).final_confidential_hold?).to be_truthy
  end

  describe 'submission#status_behavior' do
    let(:submission) { Submission.new }
    it 'responds to all methods' do
      expect(submission.status_behavior.collecting_program_information?).to be_truthy
      submission.status = 'collecting committee'
      expect(submission.status_behavior.collecting_committee?).to be_truthy
      expect(submission.status_behavior.beyond_collecting_program_information?).to be_truthy
      submission.status = 'collecting format review files'
      expect(submission.status_behavior.collecting_format_review_files?).to be_truthy
      expect(submission.status_behavior.beyond_collecting_format_review_files?).to be_falsey
    end
  end
end
