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
end
