# frozen_string_literal: true

require 'model_spec_helper'

RSpec.describe SubmissionStatus, type: :model do
  let(:submission) { FactoryBot.create :submission }

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

  it 'responds to #collecting_program_information?' do
    submission.status = 'collecting program information'
    expect(described_class.new(submission)).to be_collecting_program_information
    submission.status = 'collecting program '
    expect(described_class.new(submission)).not_to be_collecting_program_information
  end
  it 'responds to #collecting_committee?' do
    submission.status = 'collecting committee'
    expect(described_class.new(submission)).to be_collecting_committee
    submission.status = 'collecting commm'
    expect(described_class.new(submission)).not_to be_collecting_committee
  end
  it 'responds to #collecting_format_review_files?' do
    submission.status = 'collecting format review files'
    expect(described_class.new(submission)).to be_collecting_format_review_files
    submission.status = 'collecting format review files rejected'
    expect(described_class.new(submission)).to be_collecting_format_review_files
    submission.status = 'collecting format review'
    expect(described_class.new(submission)).not_to be_collecting_format_review_files
  end
  it 'responds to #collecting_format_review_files_rejected?' do
    submission.status = 'collecting format review files'
    submission.format_review_rejected_at = Time.now
    expect(described_class.new(submission)).to be_collecting_format_review_files_rejected
    submission.status = 'collecting format review files rejected'
    submission.format_review_rejected_at = Time.now
    expect(described_class.new(submission)).to be_collecting_format_review_files_rejected
    submission.status = 'collecting format review files'
    submission.format_review_rejected_at = Time.now
    submission.format_review_approved_at = Time.now
    expect(described_class.new(submission)).not_to be_collecting_format_review_files_rejected
  end
  it 'responds to #waiting_for_format_review_response?' do
    submission.status = 'waiting for format review response'
    expect(described_class.new(submission)).to be_waiting_for_format_review_response
    submission.status = 'waiting for format review respon'
    expect(described_class.new(submission)).not_to be_waiting_for_format_review_response
  end
  it 'responds to #collecting_final_submission_files?' do
    submission.status = 'collecting final submission files'
    expect(described_class.new(submission)).to be_collecting_final_submission_files
    submission.status = 'collecting final submission files rejected'
    expect(described_class.new(submission)).to be_collecting_final_submission_files
    submission.status = 'collecting final submission format review rejected'
    expect(described_class.new(submission)).not_to be_collecting_final_submission_files
  end
  it 'responds to #collecting_final_submission_files_rejected?' do
    submission.status = 'collecting final submission files'
    expect(described_class.new(submission)).not_to be_collecting_final_submission_files_rejected
    submission.status = 'collecting final submission files'
    submission.final_submission_rejected_at = Time.now
    expect(described_class.new(submission)).to be_collecting_final_submission_files_rejected
    submission.status = 'collecting final submission files rejected'
    submission.final_submission_approved_at = Time.now
    expect(described_class.new(submission)).not_to be_collecting_final_submission_files_rejected
  end
  it 'responds to #waiting_for_committee_review?' do
    submission.status = 'waiting for committee review'
    expect(described_class.new(submission)).to be_waiting_for_committee_review
    submission.status = 'waiting for committee rev'
    expect(described_class.new(submission)).not_to be_waiting_for_committee_review
  end
  it 'responds to #waiting_for_head_of_program_review?' do
    submission.status = 'waiting for head of program review'
    expect(described_class.new(submission)).to be_waiting_for_head_of_program_review
    submission.status = 'waiting for head of program re'
    expect(described_class.new(submission)).not_to be_waiting_for_head_of_program_review
  end
  it 'responds to #waiting_for_committee_review_rejected?' do
    submission.status = 'waiting for committee review rejected'
    expect(described_class.new(submission)).to be_waiting_for_committee_review_rejected
    submission.status = 'waiting for committee rev'
    expect(described_class.new(submission)).not_to be_waiting_for_committee_review_rejected
  end
  it 'responds to #waiting_for_final_submission_response?' do
    submission.status = 'waiting for final submission response'
    expect(described_class.new(submission)).to be_waiting_for_final_submission_response
    submission.status = 'waiting for final submission resp'
    expect(described_class.new(submission)).not_to be_waiting_for_final_submission_response
  end
  it 'responds to #waiting_for_publication_release?' do
    submission.status = 'waiting for publication release'
    expect(described_class.new(submission)).to be_waiting_for_publication_release
    submission.status = 'waiting for publication'
    expect(described_class.new(submission)).not_to be_waiting_for_publication_release
  end
  it 'responds to #waiting_in_final_submission_on_hold?' do
    submission.status = 'waiting in final submission on hold'
    expect(described_class.new(submission)).to be_waiting_in_final_submission_on_hold
    submission.status = 'final submission on hold'
    expect(described_class.new(submission)).not_to be_waiting_in_final_submission_on_hold
  end
  it 'responds to #released_for_publication?' do
    submission.status = 'released for publication'
    expect(described_class.new(submission)).to be_released_for_publication
    submission.status = 'released for publication metadata only'
    expect(described_class.new(submission)).to be_released_for_publication
  end
  it 'responds to #released_for_publication_metadata_only?' do
    submission.status = 'released for publication metadata only'
    submission.access_level = 'restricted'
    expect(described_class.new(submission)).to be_released_for_publication_metadata_only
    submission.access_level = 'restricted_to_institution'
    expect(described_class.new(submission)).not_to be_released_for_publication_metadata_only
  end
  it 'responds to #beyond_collecting_program_information?' do
    submission.status = 'released for publication'
    expect(described_class.new(submission)).to be_beyond_collecting_program_information
    submission.status = ''
    expect(described_class.new(submission)).not_to be_beyond_collecting_program_information
  end
  it 'responds to #beyond_collecting_committee?' do
    submission.status = 'released for publication'
    expect(described_class.new(submission)).to be_beyond_collecting_committee
    submission.status = ''
    expect(described_class.new(submission)).not_to be_beyond_collecting_committee
  end
  it 'responds to #beyond_collecting_format_review_files?' do
    submission.status = 'released for publication'
    expect(described_class.new(submission)).to be_beyond_collecting_format_review_files
    submission.status = 'waiting for format review response'
    expect(described_class.new(submission)).to be_beyond_collecting_format_review_files
    submission.status = ''
    expect(described_class.new(submission)).not_to be_beyond_collecting_format_review_files
  end
  it 'responds to #beyond_waiting_for_format_review_response?' do
    submission.status = 'released for publication'
    expect(described_class.new(submission)).to be_beyond_waiting_for_format_review_response
    submission.status = 'waiting for format review response'
    expect(described_class.new(submission)).not_to be_beyond_waiting_for_format_review_response
    submission.status = ''
    expect(described_class.new(submission)).not_to be_beyond_waiting_for_format_review_response
  end
  it 'responds to #beyond_waiting_for_committee_review?' do
    submission.status = 'waiting for head of program review'
    expect(described_class.new(submission)).to be_beyond_waiting_for_committee_review
    submission.status = 'waiting for final submission response'
    expect(described_class.new(submission)).to be_beyond_waiting_for_committee_review
    submission.status = 'waiting for format review response'
    expect(described_class.new(submission)).not_to be_beyond_waiting_for_committee_review
    submission.status = 'waiting for publication release'
    expect(described_class.new(submission)).to be_beyond_waiting_for_committee_review
  end
  it 'responds to #beyond_waiting_for_head_of_program_review?' do
    submission.status = 'waiting for publication release'
    expect(described_class.new(submission)).to be_beyond_waiting_for_head_of_program_review
    submission.status = 'waiting for final submission response'
    expect(described_class.new(submission)).to be_beyond_waiting_for_head_of_program_review
    submission.status = 'waiting for format review response'
    expect(described_class.new(submission)).not_to be_beyond_waiting_for_head_of_program_review
    submission.status = 'waiting for publication release'
    expect(described_class.new(submission)).to be_beyond_waiting_for_head_of_program_review
  end
  it 'responds to #beyond_waiting_for_final_submission_response?' do
    submission.status = 'waiting for publication release'
    expect(described_class.new(submission)).to be_beyond_waiting_for_final_submission_response
    submission.status = 'released for publication metadata only'
    expect(described_class.new(submission)).to be_beyond_waiting_for_final_submission_response
    submission.status = ''
    expect(described_class.new(submission)).not_to be_beyond_waiting_for_final_submission_response
  end
  it 'responds to #ok_to_update_committee?' do
    submission.status = 'collecting program information'
    expect(described_class.new(submission)).not_to be_ok_to_update_committee
    submission.status = 'released for publication metadata only'
    expect(described_class.new(submission)).not_to be_ok_to_update_committee
    submission.status = 'collecting final submission files rejected'
    expect(described_class.new(submission)).to be_ok_to_update_committee
    submission.status = 'collecting format review files'
    expect(described_class.new(submission)).to be_ok_to_update_committee
    submission.status = 'collecting final submission files'
    expect(described_class.new(submission)).to be_ok_to_update_committee
  end

  describe 'submission#status_behavior' do
    let(:submission) { Submission.new }

    it 'responds to all methods' do
      expect(submission.status_behavior).to be_collecting_program_information
      submission.status = 'collecting committee'
      expect(submission.status_behavior).to be_collecting_committee
      expect(submission.status_behavior).to be_beyond_collecting_program_information
      submission.status = 'collecting format review files'
      expect(submission.status_behavior).to be_collecting_format_review_files
      expect(submission.status_behavior).not_to be_beyond_collecting_format_review_files
    end
  end
end
