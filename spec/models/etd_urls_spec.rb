require 'model_spec_helper'

RSpec.describe EtdUrls, :honors, :milsch, type: :model do
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

  context 'workflow urls' do
    it 'returns graduate url' do
      expect(described_class.new.workflow).to eql('https://submit-etda-test.libraries.psu.edu.localhost:3000') if current_partner.graduate?
    end

    it 'returns honors url' do
      expect(described_class.new.workflow).to eql('https://submit-honors-test.libraries.psu.edu.localhost:3000') if current_partner.honors?
    end

    it 'returns milsch url' do
      expect(described_class.new.workflow).to eql('https://submit-millennium-scholars-test.libraries.psu.edu.localhost:3000') if current_partner.milsch?
    end
  end
end
