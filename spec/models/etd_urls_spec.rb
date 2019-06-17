require 'model_spec_helper'

RSpec.describe EtdUrls, type: :model do
  context 'explore urls' do
    it 'returns graduate url' do
      expect(described_class.new.explore).to eql('http://etda.localhost:3000/') if current_partner.graduate?
    end
    it 'returns honors url' do
      expect(described_class.new.explore).to eql('http://honors.localhost:3000/') if current_partner.honors?
    end
    it 'returns milsch url' do
      expect(described_class.new.explore).to eql('http://millennium-scholars.localhost:3000/') if current_partner.milsch?
    end
  end

  context 'explore urls' do
    it 'returns graduate url' do
      expect(described_class.new.workflow).to eql('https://submit-etda-.libraries.psu.edu.localhost:3000/') if current_partner.graduate?
    end
    it 'returns honors url' do
      expect(described_class.new.workflow).to eql('https://submit-honors-.libraries.psu.edu.localhost:3000/') if current_partner.honors?
    end
    it 'returns milsch url' do
      expect(described_class.new.workflow).to eql('https://submit-millennium-scholars-.libraries.psu.edu.localhost:3000/') if current_partner.milsch?
    end
  end


  context '#popup' do
    it 'graduate and honors are blank' do
      expect(described_class.new.popup).to be_blank unless current_partner.milsch?
    end
    it 'returns an alert for millennium scholars' do
      expect(described_class.new.popup).to eql("alert('Millennium Scholars Explore Coming Soon'); return false;") if current_partner.milsch?
    end
  end
end
