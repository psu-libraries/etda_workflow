# frozen_string_literal: true

require 'model_spec_helper'
require 'invention_disclosure_number_validator'

RSpec.describe InventionDisclosure, type: :model do
  it { is_expected.to have_db_column(:submission_id).of_type(:integer) }
  it { is_expected.to have_db_column(:id_number).of_type(:string) }
  it { is_expected.to belong_to :submission }

  describe 'requires an invention disclosure number with correct formatting' do
    let(:submission) { FactoryBot.create :submission, :collecting_final_submission_files }
    let(:invention_disclosure) { described_class.new(submission_id: submission.id) }
    let(:this_year) { Time.zone.now.year.to_s }
    let(:last_year) { (Time.zone.now.year - 1).to_s }

    before do
      submission.access_level = 'restricted'
      submission.author_edit = true
      submission.invention_disclosures << invention_disclosure
    end

    context 'when given a valid id number' do
      it 'is valid' do
        submission.invention_disclosure.id_number = "#{this_year}-1234"
        expect(submission).to be_valid
        expect(submission.errors[:invention_disclosure]).to eql([])
      end
    end

    context 'it cannot be empty' do
      it 'is not valid' do
        submission.access_level = 'restricted'
        submission.valid?
        expect(submission.errors[:invention_disclosure]).to eql(['number is required for Restricted submissions.'])
        submission.invention_disclosure.id_number = '       '
        submission.valid?
        expect(submission.errors[:invention_disclosure]).to eql(["number is required for Restricted submissions."])
      end
    end

    context 'can be blank if submission is not restricted' do
      it 'is valid' do
        submission.invention_disclosure.id_number = ''
        submission.update access_level: 'open_access'
        submission.valid?
        expect(submission.errors[:invention_disclosure]).to eql([])
      end
    end

    context 'an invention disclosure number should not be present when submission is not restricted' do
      it 'is invalid' do
        submission.author_edit = true
        submission.access_level = 'open_access'
        submission.invention_disclosure.id_number = '2016-1234'
        submission.valid?
        expect(submission.errors[:invention_disclosure]).to eql([])
        # expect(submission.errors[:invention_disclosure]).to eql([' number should only be entered when Restricted access is selected.  Please remove the Invention Disclosure Number or select restricted access.'])
      end
    end

    context 'it displays a message' do
      it 'has a description' do
        expect(InventionDisclosure.description).to eq('The Restricted option should be used exclusively for authors with patent issues.  Authors using this option are required to file an Invention Disclosure form with the Intellectual Property Office in order to obtain an Invention Disclosure Number.')
      end

      it 'has a prefix length' do
        expect(InventionDisclosure.prefix_range).to eq(8)
      end
    end
  end
end
