# frozen_string_literal: true

require 'model_spec_helper'

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
  it { is_expected.to have_db_column(:remember_created_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:sign_in_count).of_type(:integer) }
  it { is_expected.to have_db_column(:last_sign_in_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:current_sign_in_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:current_sign_in_ip).of_type(:string) }
  it { is_expected.to have_db_column(:last_sign_in_ip).of_type(:string) }
  it { is_expected.to have_db_column(:country).of_type(:string) }
  it { is_expected.to have_db_column(:psu_idn).of_type(:string) }
  it { is_expected.to have_db_column(:confidential_hold).of_type(:boolean) }
  it { is_expected.to have_db_column(:confidential_hold_set_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:admin_edited_at).of_type(:datetime) }
  it { is_expected.to validate_presence_of(:access_id) }
  it { is_expected.to validate_presence_of(:first_name) }
  it { is_expected.to validate_presence_of(:last_name) }
  it { is_expected.to validate_presence_of(:psu_email_address) }
  it { is_expected.to validate_presence_of(:alternate_email_address) }
  it { is_expected.to validate_presence_of(:psu_idn) }

  it { is_expected.to validate_uniqueness_of(:access_id) }
  it { is_expected.to validate_uniqueness_of(:psu_idn) }
  it { is_expected.to validate_uniqueness_of(:legacy_id) }

  if current_partner.graduate?
    it { is_expected.to validate_presence_of(:phone_number) }
    it { is_expected.to validate_presence_of(:address_1) }
    it { is_expected.to validate_presence_of(:city) }
    it { is_expected.to validate_presence_of(:state) }
    it { is_expected.to validate_presence_of(:zip) }

    it 'only accepts correctly formatted email addresses' do
      expect(FactoryBot.build(:author, alternate_email_address: 'xyz-123@yahoo.com')).to be_valid
      expect(FactoryBot.build(:author, alternate_email_address: 'someone@smith.ac.nz')).to be_valid
      expect(FactoryBot.build(:author, alternate_email_address: 'abc123@cse.psu.edu')).to be_valid
      expect(FactoryBot.build(:author, alternate_email_address: 'xyz-123 .com')).not_to be_valid
      expect(FactoryBot.build(:author, alternate_email_address: 'abc123@.psu.edu')).not_to be_valid
    end

    it 'only accepts correctly formatted psu_idn numbers' do
      expect(FactoryBot.build(:author, psu_idn: '912345678')).to be_valid
      expect(FactoryBot.build(:author, psu_idn: '901287085')).to be_valid
      expect(FactoryBot.build(:author, psu_idn: '91234567a')).not_to be_valid
      expect(FactoryBot.build(:author, psu_idn: '91234567.')).not_to be_valid
      expect(FactoryBot.build(:author, psu_idn: '9123456')).not_to be_valid
      expect(FactoryBot.build(:author, psu_idn: '9123456789')).not_to be_valid
      expect(FactoryBot.build(:author, psu_idn: '712345678')).not_to be_valid
      expect(FactoryBot.build(:author, psu_idn: '9123456-8')).not_to be_valid
    end

    it 'does not check format of phone number' do
      expect(FactoryBot.build(:author, legacy_id: 1, phone_number: '123-xyz-7890')).to be_valid
      expect(FactoryBot.build(:author, legacy_id: 1, phone_number: '1234-567890')).to be_valid
      expect(FactoryBot.build(:author, legacy_id: 1, phone_number: '123456789')).to be_valid
      expect(FactoryBot.build(:author, legacy_id: 1, phone_number: '12345678901')).to be_valid
    end

    it 'expects correctly formatted zip code if one is entered for graduate authors' do
      author = FactoryBot.build(:author)
      author.zip = '078431=1234'
      expect(author).not_to be_valid
      author.zip = '07843-12345'
      expect(author).not_to be_valid
      author.zip = 'AB843-1234'
      expect(author).not_to be_valid
      author.zip = '12345-1234'
      expect(author).to be_valid
      author.zip = '12345'
      expect(author).to be_valid
      author.zip = '1234'
      expect(author).not_to be_valid
      author.zip = '12345-123'
      expect(author).not_to be_valid
      author.zip = '123456-12345'
      expect(author).not_to be_valid
    end
  end

  unless current_partner.graduate?
    context 'non graduate students are not expected to have contact address fields', honors: true, milsch: true do
      it { is_expected.not_to validate_inclusion_of(:state).in_array(UsStates.names.keys.map(&:to_s)) }
      it { is_expected.not_to validate_presence_of(:state) }
      it { is_expected.not_to validate_presence_of(:zip) }
      it { is_expected.not_to validate_presence_of(:address_1) }
      it { is_expected.not_to validate_presence_of(:phone_number) }
    end
  end

  it { is_expected.to have_db_index(:legacy_id) }

  describe '#ldap_results_valid?' do
    it 'returns false if results are empty' do
      expect(described_class.new(access_id: 'testid').send('ldap_results_valid?', nil)).to be_falsey
    end

    it 'returns false if access_ids do not match' do
      expect(described_class.new(access_id: 'wrongid').send('ldap_results_valid?', access_id: 'testid', first_name: "xtester", middle_name: "xmiddle", last_name: "xlast", address_1: "TSB Building", city: "University Park", state: "PA", zip: "16802", phone_number: "555-555-5555", country: "US", psu_idn: "999999999")).to be_falsey
    end

    it 'returns true if results are not empty' do
      expect(described_class.new(access_id: 'testid').send('ldap_results_valid?', access_id: 'testid', first_name: "xtester", middle_name: "xmiddle", last_name: "xlast", address_1: "TSB Building", city: "University Park", state: "PA", zip: "16802", phone_number: "555-555-5555", country: "US", psu_idn: "999999999")).to be_truthy
    end
  end

  describe '#refresh_important_attributes' do
    let(:author_update_results) { { access_id: 'testid', first_name: ' ', middle_name: 'Yhoo', last_name: 'Ilast', address_1: '0116 H Technology Sppt Bldg', city: 'University Park', state: 'PA', country: '', zip: '16802', phone_number: '814-456-7890', psu_idn: '988888888', confidential_hold: true } }

    it 'populates PSU id number if it is not present' do
      allow_any_instance_of(LdapUniversityDirectory).to receive('retrieve').with('testid', 'uid', LdapResultsMap::AUTHOR_LDAP_MAP).and_return(author_update_results)
      author = described_class.new(access_id: 'testid')
      author.save(validate: false)
      expect(author.psu_idn).to be_nil
      author.refresh_important_attributes
      expect(author.psu_idn).not_to be_nil
    end

    it 'updates PSU idn number' do
      allow_any_instance_of(LdapUniversityDirectory).to receive('retrieve').with('testid', 'uid', LdapResultsMap::AUTHOR_LDAP_MAP).and_return(author_update_results)
      author = described_class.new(access_id: 'testid')
      author.psu_idn = 'xxxxxxxxx'
      author.save(validate: false)
      author.refresh_important_attributes
      expect(author.psu_idn).not_to eq('xxxxxxxxx')
      expect(author.psu_idn).to eq('988888888')
    end

    it 'updates author name as long as the attribute is not blank in LDAP' do
      allow_any_instance_of(LdapUniversityDirectory).to receive('retrieve').with('testid', 'uid', LdapResultsMap::AUTHOR_LDAP_MAP).and_return(author_update_results)
      author = described_class.new(access_id: 'testid')
      author.last_name = 'beforelast'
      author.first_name = 'beforefirst'
      author.middle_name = 'middle'
      author.middle_name = 'beforemiddle'
      author.confidential_hold = nil
      author.save(validate: false)
      author.refresh_important_attributes
      expect(author.psu_idn).not_to eq('xxxxxxxxx')
      expect(author.psu_idn).to eq('988888888')
      expect(author.last_name).to eq('Ilast')
      expect(author.first_name).not_to eq(' ')
      expect(author.first_name).to eq('beforefirst')
      expect(author.middle_name).to eq('Yhoo')
    end

    it 'updates author psu_email_address if blank' do
      allow_any_instance_of(LdapUniversityDirectory).to receive('retrieve').with('testid', 'uid', LdapResultsMap::AUTHOR_LDAP_MAP).and_return(author_update_results)
      author = described_class.new(access_id: 'testid')
      author.psu_email_address = nil
      author.refresh_important_attributes
      expect(author.psu_email_address).to eq('testid@psu.edu')
    end
  end

  describe '#can_edit?' do
    it 'allows the author to edit his or her own record' do
      described_class.current = described_class.new(access_id: 'ME123')
      expect(described_class.new(access_id: 'me123')).to be_can_edit
    end

    it "does not allow an author to edit someone else's personal information" do
      described_class.current = described_class.new(access_id: 'me123')
      expect { described_class.new(access_id: 'somebodyelse456').can_edit? }.to raise_error(Author::NotAuthorizedToEdit)
    end
  end

  describe '#legacy' do
    it 'identifies legacy records' do
      expect(described_class.new(access_id: 'me123', legacy_id: nil)).not_to be_legacy
      expect(described_class.new(access_id: 'me123', legacy_id: '1')).to be_legacy
    end
  end

  describe 'confidential?' do
    author = described_class.new
    context 'author does not have a confidential hold' do
      it 'returns false' do
        author.confidential_hold = false
        expect(author).not_to be_confidential
      end

      it 'returns true' do
        author.confidential_hold = true
        expect(author).to be_confidential
      end

      it 'returns false if value is nil' do
        author.confidential_hold = nil
        expect(author).not_to be_confidential
      end
    end
  end

  describe '#populate_attributes' do
    author = described_class.new(access_id: 'xyz123', psu_email_address: 'xyz123')
    author.save validate: false
    let(:author_ldap_results) { { access_id: 'xyz123', first_name: 'Xyzlaphon', middle_name: 'Yhoo', last_name: 'Zebra', address_1: 'University Libraries', city: 'University Park', state: 'PA', country: '', zip: '16802', phone_number: '814-123-4567', psu_idn: '988888888', confidential_hold: false } }

    before do
      allow(ConfidentialHoldUpdateService).to receive(:grab_ldap_results).and_return({ confidential_hold: true })
      allow(ConfidentialHoldHistory).to receive(:create).and_return nil
    end

    it 'updates author attributes using LDAP information ' do
      expect(author.last_name).to be_blank
      expect(author.confidential_hold).to be_blank
      expect(author.phone_number).to be_blank
      allow_any_instance_of(LdapUniversityDirectory).to receive('retrieve').with('xyz123', 'uid', LdapResultsMap::AUTHOR_LDAP_MAP).and_return(author_ldap_results)
      author.populate_attributes
      expect(author.last_name).to eql('Zebra')
      expect(author.phone_number).to eql('814-123-4567')
      expect(author.full_name).to eql("#{author.first_name} #{author.middle_name} #{author.last_name}")
      expect(author.confidential_hold).to be true
    end
  end

  describe '#populate_attributes' do
    author = described_class.new(access_id: 'bbb123', psu_email_address: 'bbb123')
    author.save validate: false
    let(:author_ldap_results) { { access_id: 'bbb123', first_name: '', middle_name: '', last_name: '', address_1: '', city: 'University Park', state: 'PA', country: '', zip: '16802', phone_number: '', psu_idn: '988888888', confidential_hold: true } }

    it 'populates first and last name with access_id and a message when LDAP does not return those fields' do
      expect(author.last_name).to be_blank
      expect(author.phone_number).to be_blank
      allow_any_instance_of(LdapUniversityDirectory).to receive('retrieve').with('bbb123', 'uid', LdapResultsMap::AUTHOR_LDAP_MAP).and_return(author_ldap_results)
      author.populate_attributes
      expect(author.first_name).to eql(author.access_id.to_s)
      expect(author.phone_number).to eql('')
      expect(author.last_name).to eql('No Associated Name')
      expect(author.confidential_hold).to be_truthy
      expect(author.full_name).to eql("#{author.first_name} No Associated Name")
    end
  end

  describe '#full_name' do
    it 'combines first and last name' do
      author = FactoryBot.create :author
      expect(author.full_name).to eql(author.first_name + ' ' + author.middle_name + ' ' + author.last_name)
    end

    it 'returns access_id if name is missing' do
      author = FactoryBot.create :author
      author.first_name = nil
      author.last_name = nil
      expect(author.full_name).to eql(author.access_id)
    end
  end

  describe '#psu_id_number' do
    it 'returns the psu_id number from ldap' do
      author = FactoryBot.create :author
      author.access_id = 'xxb13'
      ldap_psu_id = author.psu_id_number(author)
      expect(ldap_psu_id).to eq('999999999')
    end
  end
end
