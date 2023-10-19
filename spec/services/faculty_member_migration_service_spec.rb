# frozen_string_literal: true

require 'rails_helper'
require 'shoulda-matchers'

RSpec.describe FacultyMemberMigrationService do
  let!(:committee_member1) { FactoryBot.create :committee_member, access_id: 'abc123' } # not in ldap
  let!(:committee_member2) { FactoryBot.create :committee_member, access_id: 'xyz123', name: "Dr. John A Smith" } # middle name, prefix
  let!(:committee_member3) { FactoryBot.create :committee_member, access_id: 'psu123', name: "Our Test Jr" } # suffix
  let!(:committee_member4) { FactoryBot.create :committee_member, access_id: 'psu123', name: "Our Test Jr" }
  let!(:committee_member5) { FactoryBot.create :committee_member, access_id: 'abc456' }
  let!(:faculty_member1) { FactoryBot.create :faculty_member, webaccess_id: 'abc456' }
  let!(:committee_member6) { FactoryBot.create :committee_member, access_id: 'psu789', name: "Member Test" }

  let!(:ldap_base) { Rails.application.config_for(:ldap)['base'] }

  let!(:params1) { { base: ldap_base, filter: Net::LDAP::Filter.eq('uid', committee_member1.access_id), attributes: [] } }
  let!(:params2) { { base: ldap_base, filter: Net::LDAP::Filter.eq('uid', committee_member2.access_id), attributes: [] } }
  let!(:params3) { { base: ldap_base, filter: Net::LDAP::Filter.eq('uid', committee_member3.access_id), attributes: [] } }
  let!(:params4) { { base: ldap_base, filter: Net::LDAP::Filter.eq('cn', ' John A Smith'), attributes: [] } }
  let!(:params5) { { base: ldap_base, filter: Net::LDAP::Filter.eq('cn', 'John Smith'), attributes: [] } }
  let!(:params6) { { base: ldap_base, filter: Net::LDAP::Filter.eq('cn', 'Our Test '), attributes: [] } }
  let!(:params7) { { base: ldap_base, filter: Net::LDAP::Filter.eq('uid', committee_member6.access_id), attributes: [] } }
  # remove params8 after backfill is completed
  let!(:params8) { { base: ldap_base, filter: Net::LDAP::Filter.eq('uid', committee_member5.access_id), attributes: [] } }

  let!(:empty_result) { [] }
  let!(:result1) { [{ givenname: ["Jane"], cn: ["Jane Doe"], sn: ["Doe"], psdepartment: ["Library Strategic Technologies"], edupersonprimaryaffiliation: ["STAFF"], uid: ["abc123"], psbusinessarea: ["IST"] }] }
  let!(:result2) { [{ givenname: ["John"], cn: ["John A. Smith"], sn: ["Smith"], psdepartment: ["Library Strategic Technologies"], edupersonprimaryaffiliation: ["STAFF"], uid: ["xyz123"], psbusinessarea: ["IST"] }] }
  let!(:result3) { [{ givenname: ["Our"], cn: ["Our Test Jr"], sn: ["Test"], psdepartment: ["Library Strategic Technologies"], edupersonprimaryaffiliation: ["STAFF"], uid: ["psu123"], psbusinessarea: ["IST"] }] }
  let!(:result4) { [{ givenname: ["Member"], cn: ["Member Test"], sn: ["Test"], psdepartment: ["Library Strategic Technologies"], edupersonprimaryaffiliation: ["MEMBER"], uid: ["psu789"], psbusinessarea: ["IST"] }] }
  # remove result 5 after backfill is completed
  let!(:result5) { [{ givenname: ["Jane"], cn: ["Jane Doe"], sn: ["Doe"], psdepartment: ["Library Strategic Technologies"], edupersonprimaryaffiliation: ["STAFF"], uid: ["abc123"], psbusinessarea: ["IST"] }] }

  describe '#migrate_faculty_members' do
    before do
      allow_any_instance_of(MockUniversityDirectory::FakeConnection).to receive(:search)
      allow_any_instance_of(MockUniversityDirectory::FakeConnection).to receive(:search).with(**params1).and_return(result1)
      allow_any_instance_of(MockUniversityDirectory::FakeConnection).to receive(:search).with(**params2).and_return(empty_result)
      allow_any_instance_of(MockUniversityDirectory::FakeConnection).to receive(:search).with(**params3).and_return(empty_result)
      allow_any_instance_of(MockUniversityDirectory::FakeConnection).to receive(:search).with(**params4).and_return(empty_result)
      allow_any_instance_of(MockUniversityDirectory::FakeConnection).to receive(:search).with(**params5).and_return(result2)
      allow_any_instance_of(MockUniversityDirectory::FakeConnection).to receive(:search).with(**params6).and_return(result3)
      allow_any_instance_of(MockUniversityDirectory::FakeConnection).to receive(:search).with(**params7).and_return(result4)
      # remove bottom allow statement after backfill is completed
      allow_any_instance_of(MockUniversityDirectory::FakeConnection).to receive(:search).with(**params8).and_return(result5)
    end

    it 'Creates Faculty Members' do
      expect { described_class.new.migrate_faculty_members }.to change(FacultyMember, :count).by 3
      expect(FacultyMember.count).to eq 4
      expect(FacultyMember.find_by(webaccess_id: "psu123").committee_members).to eq [committee_member3, committee_member4]
      expect(committee_member1.reload.faculty_member_id).to eq FacultyMember.find_by(webaccess_id: "abc123").id
      expect(committee_member5.reload.faculty_member_id).to eq FacultyMember.find_by(webaccess_id: "abc456").id
      expect(FacultyMember.find_by(webaccess_id: "abc123").first_name).to eq "Jane"
      expect(FacultyMember.find_by(webaccess_id: "abc123").last_name).to eq "Doe"
      expect(FacultyMember.find_by(webaccess_id: "abc123").department).to eq "Library Strategic Technologies"
      expect(FacultyMember.find_by(webaccess_id: "xyz123").middle_name).to eq "A"
      expect(FacultyMember.find_by(webaccess_id: "abc123").college).to eq "IST"
    end
  end
end
