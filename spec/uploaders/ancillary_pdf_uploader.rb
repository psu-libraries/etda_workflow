require 'carrierwave/test/matchers'
require 'rails_helper'

RSpec.describe AncillaryPdfUploader do
  include CarrierWave::Test::Matchers

  let(:uploader) { described_class.new }

  before do
    described_class.enable_processing = true
  end

  after do
    described_class.enable_processing = false
    uploader.remove!
  end

  it "only allows pdfs to be uploaded" do
    allow(uploader).to receive(:asset_prefix).and_return('files')
    allow(uploader).to receive(:asset_hash).and_return('01/10')
    expect { File.open('spec/fixtures/format_review_file_03.docx') { |f| uploader.store!(f) } }.to raise_error(CarrierWave::IntegrityError)
    expect { File.open('spec/fixtures/ancillary_file.pdf') { |f| uploader.store!(f) } }.not_to raise_error
  end
end
