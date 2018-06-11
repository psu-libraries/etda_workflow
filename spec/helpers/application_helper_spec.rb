require 'model_spec_helper'

RSpec.describe ApplicationHelper do
  describe "#even_odd" do
    it "returns odd when the next column number is odd" do
      expect(even_odd(1)).to eq('')
    end
    it 'returns nothing when the column number is even' do
      expect(even_odd(2)).to eq('odd')
    end
  end

  describe '#invention_disclosure_number' do
    submission = Submission.new
    it 'returns nothing when a submission does not have a invention disclosure number' do
      submission.invention_disclosures = []
      expect(invention_disclosure_number(submission)).to eq('')
    end
    it 'returns the invention disclosure number if it exists' do
      submission.invention_disclosures << InventionDisclosure.new(id_number: '2018-aAbC')
      expect(invention_disclosure_number(submission)).to eq('2018-aAbC')
    end
  end

  describe '#current_version_number' do
    it "returns the application's current version number" do
      expect(current_version_number).to eql('Version: v.101-test')
    end
  end
  describe '#render_conditional_links' do
    xit 'displays admin support link when admin pages are displayed' do
      # allow(request.path).to receive(:starts_with?).with('/admin').and_return(false)
      # Author.current = nil
      # expect(render_conditional_links).to render('shared/ask_link')
      #
      # if Author.current.blank?
      #   render partial: 'shared/ask_link'
      # elsif request.path.start_with? '/admin'
      #   render partial: 'shared/admin_support_link'
      # end
    end
  end
end
