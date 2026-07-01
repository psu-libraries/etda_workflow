# frozen_string_literal: true

require 'model_spec_helper'
require 'shared/shared_examples_for_university_directory'

# These tests are for LdapUniversityDirectory, but we mock LdapUniversityDirectory
# everywhere else in the test suite with MockUniversityDirectory.  So, we override
# TestLdapUniversityDirectory with LdapUniversityDirectory in autoload_constants.rb
# and call it TestLdapUniversityDirectory here.
RSpec.describe TestLdapUniversityDirectory, type: :model do
  subject(:directory) { described_class.new }

  def build_entry(attrs)
    entry = Net::LDAP::Entry.new('uid=test-user,dc=example,dc=edu')
    attrs.each { |key, value| entry[key.to_sym] = value }
    entry
  end

  it_behaves_like 'a UniversityDirectory'

  describe '#autocomplete' do
    let(:search_string) { 'Sample User' }
    let(:results) { directory.autocomplete(search_string) }
    let(:connection) { instance_double('Net::LDAP') }
    let(:operation_result) { instance_double('OperationResult', message: operation_message) }
    let(:operation_message) { 'Success' }
    let(:ldap_records) do
      [
        build_entry(
          'displayname' => ['SAMPLE USER'],
          'mail' => ['sample.user@psu.edu'],
          'psadminarea' => ['SHARED SERVICES'],
          'psdepartment' => ['INFORMATION TECHNOLOGY']
        ),
        build_entry(
          'displayname' => ['ANOTHER USER'],
          'psadminarea' => ['SHARED SERVICES']
        )
      ]
    end

    let(:psu_identity_client) { instance_double(PsuIdentity::SearchService::Client) }
    let(:person_1) { instance_double('Person', user_id: 'abc123', affiliation: ['FACULTY']) }
    let(:person_2) { instance_double('Person', user_id: 'def456', affiliation: ['RETIREE']) }

    before do
      allow(psu_identity_client).to receive(:search).and_return([person_1, person_2])
      allow(PsuIdentity::SearchService::Client).to receive(:new).and_return(psu_identity_client)
      allow(LdapSearchFilter).to receive(:new).and_return(instance_double(LdapSearchFilter, create_filter: Net::LDAP::Filter.eq('uid', 'abc123')))
      allow(connection).to receive_messages(search: ldap_records, get_operation_result: operation_result)
      allow(directory).to receive(:with_connection).and_yield(connection)
      allow(directory).to receive(:ldap_configuration).and_return('base' => 'dc=example,dc=edu')
    end

    context 'when term is blank' do
      let(:search_string) { '' }

      it 'returns an empty array' do
        expect(results).to eq([])
      end
    end

    context 'when search filter is nil' do
      before do
        allow(LdapSearchFilter).to receive(:new).and_return(instance_double(LdapSearchFilter, create_filter: nil))
      end

      it 'returns an empty array' do
        expect(results).to eq([])
      end
    end

    context 'when LDAP reports size limit exceeded' do
      let(:operation_message) { 'Size Limit Exceeded' }

      it 'returns an empty array' do
        expect(results).to eq([])
      end
    end

    context 'when LDAP operation is not successful' do
      let(:operation_message) { 'Operations Error' }

      it 'raises ResultError' do
        expect { results }.to raise_error(described_class::ResultError)
      end
    end

    context 'when records are returned successfully' do
      it 'maps autocomplete attributes and defaults' do
        expect(results).to eq([
                                {
                                  label: 'Sample User',
                                  value: 'Sample User',
                                  id: 'sample.user@psu.edu',
                                  dept: 'Information Technology'
                                },
                                {
                                  label: 'Another User',
                                  value: 'Another User',
                                  id: 'Email not available',
                                  dept: 'Department not available'
                                }
                              ])
        expect(connection).to have_received(:search).with(base: 'dc=example,dc=edu',
                                                          filter: Net::LDAP::Filter.eq('uid', 'abc123'),
                                                          attributes: %w[cn displayname mail psadminarea psdepartment],
                                                          return_result: true)
      end
    end
  end

  describe '#exists?' do
    it 'returns true when retrieve is present' do
      allow(directory).to receive(:directory_lookup).and_return([build_entry('uid' => ['abc123'])])

      expect(directory.exists?('abc123')).to be(true)
    end

    it 'returns false when retrieve is blank' do
      allow(directory).to receive(:directory_lookup).and_return([])

      expect(directory.exists?('missing')).to be(false)
    end
  end

  describe '#retrieve' do
    let(:record) do
      build_entry(
        'uid' => ['abc123'],
        'givenname' => ['SAMPLE USER'],
        'sn' => ['EXAMPLE'],
        'postaladdress' => ['123 EXAMPLE RD$UNIVERSITY PARK, PA 16802 US'],
        'telephonenumber' => ['+1 814 555 0000'],
        'psidn' => ['999999999'],
        'psconfhold' => ['true']
      )
    end

    before do
      allow(directory).to receive(:directory_lookup).and_return([record])
    end

    it 'returns empty hash for wildcard search strings' do
      expect(directory.retrieve('abc*', 'uid', LdapResultsMap::AUTHOR_LDAP_MAP)).to eq({})
    end

    it 'returns mapped author attributes for a valid lookup' do
      result = directory.retrieve('abc123', 'uid', LdapResultsMap::AUTHOR_LDAP_MAP)

      expect(result).to include(
        access_id: 'abc123',
        first_name: 'Sample',
        middle_name: 'User',
        last_name: 'Example',
        city: 'University Park',
        state: 'PA',
        zip: '16802',
        country: 'US',
        phone_number: '814-555-0000',
        psu_idn: '999999999',
        confidential_hold: true
      )
    end
  end

  describe '#retrieve_committee_access_id' do
    it 'returns the access id when record exists' do
      allow(directory).to receive(:directory_lookup).and_return([
                                                                  build_entry(
                                                                    'uid' => ['abc123'],
                                                                    'displayname' => ['SAMPLE USER'],
                                                                    'mail' => ['sample.user@psu.edu'],
                                                                    'psadminarea' => ['SHARED SERVICES'],
                                                                    'psdepartment' => ['INFORMATION TECHNOLOGY']
                                                                  )
                                                                ])

      expect(directory.retrieve_committee_access_id('sample.user@psu.edu')).to eq('abc123')
    end

    it 'returns nil when lookup is blank' do
      allow(directory).to receive(:directory_lookup).and_return([])

      expect(directory.retrieve_committee_access_id('missing@psu.edu')).to be_nil
    end

    it 'returns nil when directory is unreachable' do
      allow(directory).to receive(:directory_lookup).and_raise(described_class::UnreachableError)

      expect(directory.retrieve_committee_access_id('sample.user@psu.edu')).to be_nil
    end
  end

  describe '#get_psu_id_number' do
    it 'returns the psu id number when available' do
      allow(directory).to receive(:directory_lookup).and_return([build_entry('psidn' => ['999999999'])])

      expect(directory.get_psu_id_number('abc123')).to eq('999999999')
    end

    it 'returns an empty string when lookup is blank' do
      allow(directory).to receive(:directory_lookup).and_return([])

      expect(directory.get_psu_id_number('missing')).to eq('')
    end
  end

  describe '#authors_confidential_status' do
    it 'returns true when psconfhold is true-like' do
      allow(directory).to receive(:directory_lookup).and_return([build_entry('psconfhold' => ['true'])])

      expect(directory.authors_confidential_status('abc123')).to be(true)
    end

    it 'returns false when psconfhold is missing' do
      allow(directory).to receive(:directory_lookup).and_return([build_entry('psconfhold' => [nil])])

      expect(directory.authors_confidential_status('abc123')).to be(false)
    end
  end

  describe '#in_admin_group?' do
    before do
      allow(directory).to receive(:current_partner).and_return(instance_double('Partner', id: 'graduate'))
    end

    it 'returns true when membership includes a recognized admin group DN' do
      allow(directory).to receive(:directory_lookup).and_return([
                                                                  build_entry(
                                                                    'psmemberof' => ['cn=umg/psu.sas.etda-graduate-admins,dc=psu,dc=edu']
                                                                  )
                                                                ])

      expect(directory.in_admin_group?('abc123')).to be(true)
    end

    it 'returns false when no recognized admin group DN is present' do
      allow(directory).to receive(:directory_lookup).and_return([
                                                                  build_entry(
                                                                    'psmemberof' => ['cn=umg/psu.some.other.group,dc=psu,dc=edu']
                                                                  )
                                                                ])

      expect(directory.in_admin_group?('abc123')).to be(false)
    end
  end
end
