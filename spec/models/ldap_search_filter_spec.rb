RSpec.describe LdapSearchFilter, type: :model do
  describe '#create_filter' do
    let(:ldap_faculty) { Net::LDAP::Filter.eq('edupersonprimaryaffiliation', "FACULTY") }
    let(:ldap_staff) { Net::LDAP::Filter.eq('edupersonprimaryaffiliation', "STAFF") }

    context 'search for first and last name' do
      let(:ldap_search) { Net::LDAP::Filter.eq('cn', 'jim* smith*') }
      let(:ldap_filter) { Net::LDAP::Filter.join(Net::LDAP::Filter.intersect(ldap_faculty, ldap_staff), ldap_search) }

      it 'returns the same filter' do
        filter = described_class.new('jim smith', true).create_filter
        expect(filter.to_json).to eql(ldap_filter.to_json)
      end
      it 'does not return the same filter' do
        filter = described_class.new('jim Jones', true).create_filter
        expect(filter.to_json).to_not eql(ldap_filter.to_json)
      end
    end

    context 'search with only first name' do
      let(:ldap_search) { Net::LDAP::Filter.eq('sn', 'lee*') }
      let(:ldap_filter) { Net::LDAP::Filter.join(Net::LDAP::Filter.intersect(ldap_faculty, ldap_staff), ldap_search) }

      it 'returns the same filter' do
        filter = described_class.new('lee ', true).create_filter
        expect(filter.to_json).to eql(ldap_filter.to_json)
      end
      it 'does not return the same filter' do
        filter = described_class.new('larry ', true).create_filter
        expect(filter.to_json).to_not eql(ldap_filter.to_json)
      end
    end
    context 'search with three names' do
      let(:ldap_search) { Net::LDAP::Filter.eq('cn', 'lee harvey oswald*') }
      let(:ldap_filter) { Net::LDAP::Filter.join(Net::LDAP::Filter.intersect(ldap_faculty, ldap_staff), ldap_search) }

      it 'returns the same filter' do
        filter = described_class.new('lee harvey oswald', true).create_filter
        expect(filter.to_json).to eql(ldap_filter.to_json)
      end
      it 'does not return the same filter' do
        filter = described_class.new('bad lee oswald', true).create_filter
        expect(filter.to_json).to_not eql(ldap_filter.to_json)
      end
    end
  end
end
