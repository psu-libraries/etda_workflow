require 'model_spec_helper'

RSpec.describe ReviewResultsEmail do
  subject(:review_results_email) { described_class.new(submission) }

  let(:submission) { FactoryBot.create :submission }

  describe 'generate' do
    it 'generates committee review results for email' do
      create_committee submission
      submission.committee_members.each do |cm|
        cm.update status: 'rejected'
        cm.update notes: 'Notes'
      end
      expect(review_results_email.generate).to eq(fixture("review_results_email.txt").read)
    end
  end
end
