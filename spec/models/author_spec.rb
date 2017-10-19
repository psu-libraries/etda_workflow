# frozen_string_literal: true
require 'rails_helper'
require 'shoulda-matchers'

RSpec.describe Author, type: :model do
  subject { described_class.new }

  it { is_expected.to have_db_column(:access_id).of_type(:string) }
  it { is_expected.to have_db_column(:first_name).of_type(:string) }
  it { is_expected.to have_db_column(:last_name).of_type(:string) }
  it { is_expected.to have_db_column(:middle_name).of_type(:string) }
  it { is_expected.to have_db_column(:alternate_email_address).of_type(:string) }
  it { is_expected.to have_db_column(:psu_email_address).of_type(:string) }
  it { is_expected.to have_db_column(:phone_number).of_type(:string) }
  it { is_expected.to have_db_column(:address_1).of_type(:string) }
  it { is_expected.to have_db_column(:address_2).of_type(:string) }
  it { is_expected.to have_db_column(:city).of_type(:string) }
  it { is_expected.to have_db_column(:state).of_type(:string) }
  it { is_expected.to have_db_column(:zip).of_type(:string) }
  it { is_expected.to have_db_column(:is_alternate_email_public).of_type(:boolean) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:legacy_id).of_type(:integer) }
  it { is_expected.to have_db_column(:confidential_hold).of_type(:boolean) }
  it { is_expected.to have_db_column(:is_admin).of_type(:boolean) }
  it { is_expected.to have_db_column(:is_site_admin).of_type(:boolean) }

  it { is_expected.to have_db_column(:remember_created_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:sign_in_count).of_type(:integer) }
  it { is_expected.to have_db_column(:remember_created_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:current_sign_in_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:last_sign_in_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:current_sign_in_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:current_sign_in_ip).of_type(:string) }
  it { is_expected.to have_db_column(:last_sign_in_ip).of_type(:string) }
  it { is_expected.to have_db_column(:country).of_type(:string) }
  it { is_expected.to have_db_column(:psu_idn).of_type(:string) }

  it { is_expected.to have_db_index(:legacy_id) }

  context '#populate_attributes' do
  end

  context '#populate_with_ldap_attributes' do
    it 'populates the author record with ldap information' do
      expect(described_class.new.to_json).to eql(described_class.new.to_json)
      expect(described_class.new(access_id: 'xxb13').populate_with_ldap_attributes).to_not eql(described_class.new.to_json)
    end
  end

  context '#ldap_results_valid?' do
    it 'returns false if results are empty' do
      expect(described_class.new(access_id: 'testid').send('ldap_results_valid?', nil)).to be_falsey
    end
    it 'returns false if access_ids do not match' do
      expect(described_class.new(access_id: 'wrongid').send('ldap_results_valid?', access_id: 'testid', first_name: "xtester", middle_name: "xmiddle", last_name: "xlast", address_1: "TSB Building", city: "University Park", state: "PA", zip: "16802", phone_number: "555-555-5555", country: "US", is_admin: true, psu_idn: "999999999"))
    end
    it 'returns true if results are not empty' do
      expect(described_class.new(access_id: 'testid').send('ldap_results_valid?', access_id: 'testid', first_name: "xtester", middle_name: "xmiddle", last_name: "xlast", address_1: "TSB Building", city: "University Park", state: "PA", zip: "16802", phone_number: "555-555-5555", country: "US", is_admin: true, psu_idn: "999999999")).to be_truthy
    end
  end

  context '#update_missing_attributes' do
    it 'populates PSU id number if it is not present' do
      author = described_class.new(access_id: 'testid')
      expect(author.psu_idn).to be_nil
      author.update_missing_attributes
      expect(author.psu_idn).not_to be_nil
    end
    it 'does not update PSU idn number if it already has a value' do
      author = described_class.new(access_id: 'testid')
      author.psu_idn = 'xxxxxxxxx'
      author.update_missing_attributes
      expect(author.psu_idn).to eq('xxxxxxxxx')
    end
  end
end
