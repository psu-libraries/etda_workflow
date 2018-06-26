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
  describe '#author_nav_active?' do
    it 'returns active class for submissions' do
      allow(controller).to receive(:controller_name).and_return('submissions')
      expect(author_nav_active?('submission')).to eq('active')
      allow(controller).to receive(:controller_name).and_return('committee_members')
      expect(author_nav_active?('submission')).to eq('active')
      allow(controller).to receive(:controller_name).and_return('format_review')
      expect(author_nav_active?('submission')).to eq('active')
    end
    it 'returns active class for authors' do
      allow(controller).to receive(:controller_name).and_return('authors')
      allow(controller).to receive(:action_name).and_return('author')
      expect(author_nav_active?('author')).to eq('active')
      allow(controller).to receive(:action_name).and_return('technical_tips')
      expect(author_nav_active?('author')).to be_nil
      expect(author_nav_active?('tips')).to eq('active')
    end
  end
  describe '#admin_nav_active?' do
    it 'returns active class for admin controllers' do
      allow(controller).to receive(:controller_name).and_return('authors')
      expect(admin_nav_active?('authors')).to eq('active')
      expect(admin_nav_active?('degrees')).to be_nil
      allow(controller).to receive(:controller_name).and_return('degrees')
      expect(admin_nav_active?('degrees')).to eq('active')
      expect(admin_nav_active?('authors')).to be_nil
      allow(controller).to receive(:controller_name).and_return('programs')
      expect(admin_nav_active?('programs')).to eq('active')
      allow(controller).to receive(:controller_name).and_return('submissions')
      expect(admin_nav_active?('submissions')).to eq('active')
      expect(admin_nav_active?('degrees')).to be_nil
      allow(controller).to receive(:controller_name).and_return('reports')
      expect(admin_nav_active?('reports')).to eq('active')
      expect(admin_nav_active?('degrees')).to be_nil
      allow(controller).to receive(:action_name).and_return('custom_report')
      expect(admin_nav_active?('custom')).to eq('active')
      expect(admin_nav_active?('reports')).to eq('active')
      allow(controller).to receive(:action_name).and_return('committee_report')
      expect(admin_nav_active?('committee')).to eq('active')
    end
  end
end
