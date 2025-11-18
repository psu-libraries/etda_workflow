# frozen_string_literal: true

require 'model_spec_helper'

RSpec.describe FederalFundingDetails, type: :model do
  describe described_class do
    let(:submission_format) { Submission.new(status: 'collecting format review files') }
    let(:submission_program) { Submission.new(status: 'collecting program information') }

    it 'requires training_support_acknowledged if training_support_funding is true' do
      details = described_class.new(training_support_funding: true, other_funding: false, submission: submission_format, author_edit: true)
      expect(details.valid?).to be(false)
      details.training_support_acknowledged = true
      expect(details.valid?).to be(true)
    end

    it 'requires other_funding_acknowledged if other_funding is true' do
      details = described_class.new(training_support_funding: false, other_funding: true, submission: submission_format, author_edit: true)
      expect(details.valid?).to be(false)
      details.other_funding_acknowledged = true
      expect(details.valid?).to be(true)
    end

    it 'only accepts true and false as values for funding used' do
      details = described_class.new(training_support_funding: false, other_funding: false, submission: submission_format, author_edit: true)
      expect(details.valid?).to be(true)
      details.training_support_funding = 'hi'
      expect(details.valid?).to be(false)
    end

    it 'does not validate if collecting program information' do
      details = described_class.new(training_support_funding: false, other_funding: true, submission: submission_program, author_edit: true)
      expect(details.valid?).to be(true)
    end

    it 'does not validate if not author edit' do
      details = described_class.new(training_support_funding: false, other_funding: true, submission: submission_format, author_edit: false)
      expect(details.valid?).to be(true)
    end

    it 'does not validate if not graduate partner', :honors do
      skip 'non graduate only' if current_partner.graduate?
      details = described_class.new(training_support_funding: false, other_funding: true, submission: submission_format, author_edit: true)
      expect(details.valid?).to be(true)
    end

    it 'uses_federal_funding? returns true if either funding type is true' do
      details = described_class.new(training_support_funding: true, other_funding: false, submission: submission_format, author_edit: true)
      details2 = described_class.new(training_support_funding: false, other_funding: true, submission: submission_format, author_edit: true)
      details3 = described_class.new(training_support_funding: true, other_funding: true, submission: submission_format, author_edit: true)
      [details, details2, details3].each do |detail|
        expect(detail.uses_federal_funding?).to be(true)
      end
    end

    it 'uses_federal_funding? returns false if both funding types are false' do
      details = described_class.new(training_support_funding: false, other_funding: false, submission: Submission.new)
      expect(details.uses_federal_funding?).to be(false)
    end

    it 'uses_federal_funding? returns nil if both funding types are nil' do
      details = described_class.new(training_support_funding: nil, other_funding: nil, submission: Submission.new)
      expect(details.uses_federal_funding?).to be_nil
    end
  end
end
