# frozen_string_literal: true
require 'model_spec_helper'
require 'etda_utilities'
# frozen_string_literal: true
require 'model_spec_helper'
require 'etda_utilities/partner'

RSpec.describe Partner, type: :model do
  describe described_class do
    subject = described_class.current
    it 'returns partner name' do
      expect(subject.name).to eq(I18n.t("#{EtdaUtilities::Partner.current.id}.partner.name"))
    end
    it 'returns partner email' do
      expect(subject.email_address).to eq(I18n.t("#{EtdaUtilities::Partner.current.id}.partner.email.address"))
    end
    it 'returns partner slug' do
      expect(subject.slug).to eq(I18n.t("#{EtdaUtilities::Partner.current.id}.partner.slug"))
    end
    it 'returns partner label' do
      expect(subject.program_label).to eq(I18n.t("#{EtdaUtilities::Partner.current.id}.program.label"))
    end
  end
end
