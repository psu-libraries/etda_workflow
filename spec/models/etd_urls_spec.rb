require 'model_spec_helper'

RSpec.describe EtdUrls, type: :model, honors: true, milsch: true do
  context 'explore urls' do
    it 'returns graduate url' do
      expect(described_class.new.explore).to eql('http://etda.localhost:3000') if current_partner.graduate?
    end

    it 'returns honors url' do
      expect(described_class.new.explore).to eql('http://honors.localhost:3000') if current_partner.honors?
    end

    it 'returns milsch url' do
      expect(described_class.new.explore).to eql('http://millennium-scholars.localhost:3000') if current_partner.milsch?
    end
  end

  context 'explore urls' do
    it 'returns graduate url' do
      expect(described_class.new.workflow).to eql('https://submit-etda-.libraries.psu.edu.localhost:3000') if current_partner.graduate?
    end

    it 'returns honors url' do
      expect(described_class.new.workflow).to eql('https://submit-honors-.libraries.psu.edu.localhost:3000') if current_partner.honors?
    end

    it 'returns milsch url' do
      expect(described_class.new.workflow).to eql('https://submit-millennium-scholars-.libraries.psu.edu.localhost:3000') if current_partner.milsch?
    end
  end
end
