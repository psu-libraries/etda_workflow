require 'rails_helper'
require 'shoulda-matchers'

RSpec.describe ConfidentialHoldUtility, type: :model do
  let(:author) { Author.new(access_id: 'confidential123', confidential_hold: nil) }

  describe '#original_confidential_status' do
    context "original_confidential_status initialization when author.confidential_hold is nil" do
      it 'returns false' do
        expect(described_class.new(author.access_id, author.confidential_hold).original_confidential_status).to eq(false)
      end
    end
    context "initialization when author.confidential_hold is not nil" do
      it 'returns false' do
        author.confidential_hold = false
        expect(described_class.new('conf123', author.confidential_hold).original_confidential_status).to eq(false)
      end
    end
  end

  describe '#new_confidential_status' do
    context 'obtains psconfhold from LDAP and sets new_confidential_status to the LDAP value' do
      it 'is true' do
        allow_any_instance_of(LdapUniversityDirectory).to receive(:exists?).with('conf123').and_return(true)
        allow_any_instance_of(LdapUniversityDirectory).to receive(:authors_confidential_status).with('conf123').and_return(true)
        expect(described_class.new('conf123', false).new_confidential_status).to eq(true)
      end
    end
    context 'obtains psconfhold from LDAP and sets new_confidential_status to false when LDAP value is false' do
      it 'is false' do
        allow_any_instance_of(LdapUniversityDirectory).to receive(:exists?).with('conf123').and_return(true)
        allow_any_instance_of(LdapUniversityDirectory).to receive(:authors_confidential_status).with('conf123').and_return(false)
        expect(described_class.new('conf123', false).new_confidential_status).to eq(false)
      end
    end
  end
  describe '#changed?' do
    context 'confidential hold has changed from false or nil to true' do
      it 'returns true' do
        allow_any_instance_of(LdapUniversityDirectory).to receive(:exists?).with('conf123').and_return(true)
        allow_any_instance_of(LdapUniversityDirectory).to receive(:authors_confidential_status).with('conf123').and_return(true)
        ch = described_class.new('conf123', false)
        expect(ch.send('changed?')).to be_truthy
      end
      it 'returns true' do
        allow_any_instance_of(LdapUniversityDirectory).to receive(:exists?).with('conf123').and_return(true)
        allow_any_instance_of(LdapUniversityDirectory).to receive(:authors_confidential_status).with('conf123').and_return(true)
        ch = described_class.new('conf123', nil)
        expect(ch.send('changed?')).to be_truthy
        expect(ch.send('changed_to_confidential?')).to be_truthy
        expect(ch.send('confidential_hold_released?')).to be_falsey
      end
    end
    context 'confidential hold has changed from true to false' do
      it 'returns true' do
        allow_any_instance_of(LdapUniversityDirectory).to receive(:authors_confidential_status).with('conf123').and_return(false)
        ch = described_class.new('conf123', true)
        expect(ch.send('changed?')).to be_truthy
        expect(ch.send('confidential_hold_released?')).to be_truthy
        expect(ch.send('changed_to_confidential?')).to be_falsey
      end
    end
  end
  describe 'hold set at' do
    it 'updates the time confidential hold was set when the hold is first set' do
      allow_any_instance_of(LdapUniversityDirectory).to receive(:authors_confidential_status).with('conf123').and_return(true)
      ch = described_class.new('conf12', false)
      expect(ch.hold_set_at(nil, true)).not_to be_nil
    end
    it 'does not update the time confidential hold was set when the hold has already been set' do
      allow_any_instance_of(LdapUniversityDirectory).to receive(:authors_confidential_status).with('conf123').and_return(true)
      ch = described_class.new('conf12', false)
      expect(ch.hold_set_at(Time.zone.yesterday, true)).to eq(Time.zone.yesterday)
    end
    it 'sets confidential_hold_set_at to nil when the hold is released' do
      allow_any_instance_of(LdapUniversityDirectory).to receive(:authors_confidential_status).with('conf123').and_return(false)
      ch = described_class.new('conf12', true)
      expect(ch.hold_set_at(Time.zone.yesterday, false)).to be_nil
    end
  end
end
