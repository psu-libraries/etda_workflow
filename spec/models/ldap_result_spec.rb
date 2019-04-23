# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LdapResult, type: :model do
  describe 'AUTOCOMPLETE_LDAP_MAP' do
    context 'Parsed LDAP attributes are returned for an LDAP entry' do
      let(:mapped_record) do
        described_class.new(ldap_record: mock_ldap_list,
                            attribute_map: LdapUniversityDirectory::AUTOCOMPLETE_LDAP_MAP[:map],
                            defaults: LdapUniversityDirectory::AUTOCOMPLETE_LDAP_MAP[:defaults]).map_directory_info
      end

      it 'returns a list of key-value pairs containing attributes mapped for a committee member dropdopwn for autocomplete' do
        expect(mapped_record[1][:label]).to eq 'Milton E Barnoff'
        expect(mapped_record[1][:value]).to eq 'Milton E Barnoff'
        expect(mapped_record[1][:id]).to eq 'meb133@psu.edu'
        expect(mapped_record[1][:dept]).to eq 'Applied Research Lab'
        expect(mapped_record[1][:access_id]).to eq 'meb133'
      end
    end

    context 'Parsed LDAP attributes are returned with missing department information' do
      let(:mock_ldap_list_with_empty_values) { mock_ldap_list.each { |k| k.except!(:mail, :uid) } }
      let(:mapped_record) do
        described_class.new(ldap_record: mock_ldap_list_with_empty_values,
                            attribute_map: LdapUniversityDirectory::AUTOCOMPLETE_LDAP_MAP[:map],
                            defaults: LdapUniversityDirectory::AUTOCOMPLETE_LDAP_MAP[:defaults]).map_directory_info
      end

      it 'returns a message when department information is missing' do
        expect(mapped_record[2][:dept]).to eq 'Department not available'
        expect(mapped_record[2][:id]).to eq 'Email not available'
        expect(mapped_record[2][:access_id]).to eq 'Access ID not available'
      end
    end
  end

  describe 'AUTHOR_LDAP_MAP' do
    context 'Parsed LDAP attributes are returned for author' do
      let(:mapped_record) do
        described_class.new(ldap_record: mock_ldap_entry,
                            attribute_map: LdapUniversityDirectory::AUTHOR_LDAP_MAP).map_directory_info
      end

      it 'returns a list containing key-value pairs mapped to ETD Author labels' do
        expect(mapped_record.first[:last_name]).to eq 'Barnoff'
        expect(mapped_record.first[:first_name]).to eq 'Joni'
        expect(mapped_record.first[:middle_name]).to eq 'Lee'
        expect(mapped_record.first[:phone_number]).to eq '814-865-4845'
        expect(mapped_record.first[:address_1]).to eq '003 E Paterno Library'
        expect(mapped_record.first[:city]).to eq 'University Park'
        expect(mapped_record.first[:state]).to eq 'PA'
        expect(mapped_record.first[:zip]).to eq '16802'
        expect(mapped_record.first[:psu_idn]).to eq('987654321')
      end
    end
  end

  describe 'COMMITTEE_LDAP_MAP' do
    context 'Parsed LDAP attributes are returned for an LDAP entry' do
      let(:mapped_record) do
        described_class.new(ldap_record: mock_ldap_list,
                            attribute_map: LdapUniversityDirectory::COMMITTEE_LDAP_MAP[:map],
                            defaults: LdapUniversityDirectory::COMMITTEE_LDAP_MAP[:defaults]).map_directory_info
      end

      it 'returns a list of key-value pairs containing attributes mapped for a committee member dropdopwn for autocomplete' do
        expect(mapped_record[1][:label]).to eq 'Milton E Barnoff'
        expect(mapped_record[1][:value]).to eq 'Milton E Barnoff'
        expect(mapped_record[1][:id]).to eq 'meb133@psu.edu'
        expect(mapped_record[1][:dept]).to eq 'Applied Research Lab'
        expect(mapped_record[1][:access_id]).to eq 'meb133'
      end
    end

    context 'Parsed LDAP attributes are returned with missing department information' do
      let(:mock_ldap_list_with_empty_values) { mock_ldap_list.each { |k| k.except!(:mail, :uid) } }
      let(:mapped_record) do
        described_class.new(ldap_record: mock_ldap_list_with_empty_values,
                            attribute_map: LdapUniversityDirectory::COMMITTEE_LDAP_MAP[:map],
                            defaults: LdapUniversityDirectory::COMMITTEE_LDAP_MAP[:defaults]).map_directory_info
      end

      it 'returns a message when department information is missing' do
        expect(mapped_record[2][:dept]).to eq 'Department not available'
        expect(mapped_record[2][:id]).to eq 'Email not available'
        expect(mapped_record[2][:access_id]).to eq 'Access ID not available'
      end
    end
  end

  describe 'ADMIN_LDAP_MAP' do
    context 'Parsed LDAP attributes are returned for administrators' do
      let(:mapped_record) do
        described_class.new(ldap_record: mock_ldap_entry,
                            attribute_map: LdapUniversityDirectory::ADMIN_LDAP_MAP).map_directory_info
      end

      it 'returns a list containing key-value pairs mapped to ETD Author labels' do
        expect(mapped_record.first[:last_name]).to eq 'Barnoff'
        expect(mapped_record.first[:first_name]).to eq 'Joni'
        expect(mapped_record.first[:phone_number]).to eq '814-865-4845'
        expect(mapped_record.first[:address_1]).to eq '003 E Paterno Library'
        expect(mapped_record.first[:psu_idn]).to eq('987654321')
        expect(mapped_record.first[:administrator]).to be_truthy
      end
    end
  end
end
