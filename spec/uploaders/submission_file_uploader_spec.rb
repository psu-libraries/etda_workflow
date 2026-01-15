require 'carrierwave/test/matchers'
require 'rails_helper'

RSpec.describe SubmissionFileUploader do
  include CarrierWave::Test::Matchers

  let(:uploader) { described_class.new }

  before do
    described_class.enable_processing = true
  end

  after do
    described_class.enable_processing = false
    uploader.remove!
  end

  it "does not allow word docs to be uploaded" do
    expect { File.open('spec/fixtures/files/format_review_file_03.docx') { |f| uploader.store!(f) } }.to raise_error(CarrierWave::IntegrityError)
  end

  describe '#asset_prefix' do
    subject(:asset_prefix) { described_class.new(model).asset_prefix }

    context "when model.class_name is 'final-submission-file'" do
      let(:model) { create :final_submission_file }

      it 'returns the final submission files path' do
        expect(asset_prefix).to eq(Rails.root.join(WORKFLOW_BASE_PATH, 'final_submission_files'))
      end
    end

    context "when model.class_name is 'admin-feedback-file'" do
      let(:model) { create :admin_feedback_file, feedback_type: 'final-submission' }

      it 'returns the admin feedback files path' do
        expect(asset_prefix).to eq(Rails.root.join(WORKFLOW_BASE_PATH, 'admin_feedback_files'))
      end
    end

    context "when model.class_name is 'remediated-final-submission-file'" do
      let(:model) { create :remediated_final_submission_file }

      it 'returns the remediated final submission files path' do
        expect(asset_prefix).to eq(Rails.root.join(WORKFLOW_BASE_PATH, 'remediated_final_submission_files'))
      end
    end

    context 'when model.class_name is anything else' do
      let(:model) { create :format_review_file }

      it 'returns the format review files path' do
        expect(asset_prefix).to eq(Rails.root.join(WORKFLOW_BASE_PATH, 'format_review_files'))
      end
    end
  end
end
