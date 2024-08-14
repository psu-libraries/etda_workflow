# frozen_string_literal: true

require 'model_spec_helper'

RSpec.describe FederalFundingDetails, type: :model do
  describe described_class do
    it 'requires training_support_acknowledged if training_support_funding is true' do
      details = described_class.new(training_support_funding: true, other_funding: false, submission: Submission.new)
      expect(details.valid?).to eq(false)
      details.training_support_acknowledged = true
      expect(details.valid?).to eq(true)
    end

    it 'requires other_funding_acknowledged if other_funding is true' do
      details = described_class.new(training_support_funding: false, other_funding: true, submission: Submission.new)
      expect(details.valid?).to eq(false)
      details.other_funding_acknowledged = true
      expect(details.valid?).to eq(true)
    end

    it 'only accepts true and false as values for funding used' do
      details = described_class.new(training_support_funding: false, other_funding: false, submission: Submission.new)
      expect(details.valid?).to eq(true)
      details.training_support_funding = 'hi'
      expect(details.valid?).to eq(false)
    end

    it 'uses_federal_funding? returns true if either funding type is true' do
      details = described_class.new(training_support_funding: true, other_funding: false, submission: Submission.new)
      details2 = described_class.new(training_support_funding: false, other_funding: true, submission: Submission.new)
      details3 = described_class.new(training_support_funding: true, other_funding: true, submission: Submission.new)
      [details, details2, details3].each do |detail|
        expect(detail.uses_federal_funding?).to eq(true)
      end
    end

    it 'uses_federal_funding? returns false if both funding types are false' do
      details = described_class.new(training_support_funding: false, other_funding: false, submission: Submission.new)
      expect(details.uses_federal_funding?).to eq(false)
    end

    it 'uses_federal_funding? returns nil if both funding types are nil' do
      details = described_class.new(training_support_funding: nil, other_funding: nil, submission: Submission.new)
      expect(details.uses_federal_funding?).to eq(nil)
    end
  end
end
