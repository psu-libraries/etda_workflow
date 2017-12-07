# frozen_string_literal: true
require 'rails_helper'
require 'shoulda-matchers'

RSpec.describe FormatReviewFile, type: :model do
  it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:submission_id).of_type(:integer) }
  it { is_expected.to have_db_column(:asset).of_type(:text) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:legacy_id).of_type(:integer) }

  it { is_expected.to have_db_index(:submission_id) }
  it { is_expected.to have_db_index(:legacy_id) }

  it { is_expected.to validate_presence_of :asset }
  it { is_expected.to validate_presence_of :submission_id }
  it { is_expected.to belong_to :submission }

  describe 'virus scanning' do
    # The .name below is required due to the way Rails reloads classes in
    # development and test modes, can't compare the actual constants
    # let(:virus_scan_is_mocked?) { VirusScanner.name == MockVirusScanner.name }
    #
    # let(:good_file) { build :format_review_file }
    #
    # let(:infected_file) do
    #   build :format_review_file,
    #         asset: File.open(fixture 'eicar_standard_antivirus_test_file.txt')
    # end
    #
    # it 'validates that the asset is virus free' do
    #   if virus_scan_is_mocked?
    #     allow(VirusScanner).to receive(:scan).and_return(double(safe?: true))
    #   end
    #   good_file.valid?
    #   expect(good_file.errors[:asset]).to be_empty
    #
    #   if virus_scan_is_mocked?
    #     allow(VirusScanner).to receive(:scan).and_return(double(safe?: false))
    #   end
    #   infected_file.valid?
    #   expect(infected_file.errors[:asset]).to include I18n.t('errors.messages.virus_free')
    # end
  end
end
