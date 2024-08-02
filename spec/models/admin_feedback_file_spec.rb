# frozen_string_literal: true

require 'model_spec_helper'

RSpec.describe AdminFeedbackFile, type: :model do
  it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:submission_id).of_type(:integer) }
  it { is_expected.to have_db_column(:asset).of_type(:text) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:feedback_type).of_type(:string) }

  it { is_expected.to validate_presence_of :asset }
  it { is_expected.to validate_presence_of :submission_id }

  it { is_expected.to belong_to :submission }

  it 'returns class name with dashes' do
    final_submission_file = described_class.new
    expect(final_submission_file.class_name).to eql('admin-feedback-file')
  end

  it 'current_location returns full path and filename' do
    submission = FactoryBot.create :submission, :waiting_for_publication_release
    admin_feedback_file = described_class.new(submission_id: submission.id)
    admin_feedback_file.id = 1234
    allow_any_instance_of(described_class).to receive(:asset_identifier).and_return('stubbed_filename.pdf')
    expect(admin_feedback_file.current_location).to eq("#{WORKFLOW_BASE_PATH}admin_feedback_files/#{EtdaFilePaths.new.detailed_file_path(admin_feedback_file.id)}stubbed_filename.pdf")
  end

  it 'full_file_path returns the full file path w/o filename' do
    submission = FactoryBot.create :submission, :waiting_for_publication_release
    admin_feedback_file = described_class.new(submission_id: submission.id)
    admin_feedback_file.id = 1234
    expect(admin_feedback_file.full_file_path).to eq("#{WORKFLOW_BASE_PATH}admin_feedback_files/#{EtdaFilePaths.new.detailed_file_path(admin_feedback_file.id)}")
  end

  describe 'feedback type validation' do
    it 'validates the inclusion of feedback type in AdminFeedbackFile.feedback_types array' do
      submission = FactoryBot.create :submission, :waiting_for_publication_release
      admin_feedback_file = described_class.new(submission_id: submission.id)
      expect(admin_feedback_file).to validate_inclusion_of(:feedback_type).in_array(described_class.feedback_types)
    end
  end
end
