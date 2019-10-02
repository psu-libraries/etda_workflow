require 'carrierwave/test/matchers'
require 'rails_helper'

describe SubmissionFileUploader do
  include CarrierWave::Test::Matchers

  let(:uploader) { SubmissionFileUploader.new }

  before do
    SubmissionFileUploader.enable_processing = true
  end

  after do
    SubmissionFileUploader.enable_processing = false
    uploader.remove!
  end

  it "does not allow word docs to be uploaded" do
    expect{ File.open('spec/fixtures/format_review_file_03.docx') { |f| uploader.store!(f) } }.to raise_error(CarrierWave::IntegrityError)
  end
end
