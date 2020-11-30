require 'model_spec_helper'

RSpec.describe Lionpath::LionpathCommitteeCreator do
  subject(:lionpath_committee_creator) { described_class }

  let!(:author) { FactoryBot.create :author, psu_idn: '999999999' }
  let!(:submission) do
    FactoryBot.create :submission, author: author, degree: degree, status: 'collecting program information'
  end
  let!(:degree) { FactoryBot.create :degree, name: 'PHD', degree_type: degree_type }
  let!(:degree_type) { DegreeType.find_by(slug: 'dissertation') }

  before do
    factory = lionpath_committee_creator.new(row, submission)
    factory.create_member
  end

  context 'when importing' do
    let(:row) do
      { 'Access ID' => 'abc123', 'Last Name' => 'Tester', 'First Name' => 'Test', 'Role' => 'C',
        'Committee' => 'DOCCM', 'Committee Long Descr' => 'Descr', 'Student ID' => '999999999' }
    end

    it 'assigns default values' do
      expect(submission.committee_members.first.name).to eq 'Test Tester'
      expect(submission.committee_members.first.email).to eq 'abc123@psu.edu'
      expect(submission.committee_members.first.access_id).to eq 'abc123'
      expect(submission.committee_members.first.submission).to eq submission
      expect(submission.committee_members.first.lionpath_uploaded_at).to be_truthy
      expect(submission.committee_members.first.is_voting).to eq true
    end
  end

  chair_codes = ["CHMJ", "H", "C", "CIMN", "CIRA", "CIMJ"]
  chair_codes.each do |code|
    context "when inbound lionpath committee member has a role of #{code}" do
      let(:row) do
        { 'Access ID' => 'abc123', 'Last Name' => 'Tester', 'First Name' => 'Test', 'Role' => code.to_s,
          'Committee' => 'DOCCM', 'Committee Long Descr' => 'Descr', 'Student ID' => '999999999' }
      end

      it 'creates a required "Committee Chair/Co-Chair"' do
        expect(submission.committee_members.first.committee_role.name).to eq 'Committee Chair/Co-Chair'
        expect(submission.committee_members.first.is_required).to eq true
      end
    end
  end

  required_cm_codes = ['CMMJ', 'CMMN', 'G', 'MN', 'M', 'N']
  required_cm_codes.each do |code|
    context "when inbound lionpath committee member has a role of #{code}" do
      let(:row) do
        { 'Access ID' => 'abc123', 'Last Name' => 'Tester', 'First Name' => 'Test', 'Role' => code.to_s,
          'Committee' => 'DOCCM', 'Committee Long Descr' => 'Descr', 'Student ID' => '999999999' }
      end

      it 'creates a required "Committee Member"' do
        expect(submission.committee_members.first.committee_role.name).to eq 'Committee Member'
        expect(submission.committee_members.first.is_required).to eq true
      end
    end
  end

  not_required_cm_codes = ['MAMJ', 'MARA', 'MASP', 'MAGS', 'MAMN', 'CMRA']
  not_required_cm_codes.each do |code|
    context "when inbound lionpath committee member has a role of #{code}" do
      let(:row) do
        { 'Access ID' => 'abc123', 'Last Name' => 'Tester', 'First Name' => 'Test', 'Role' => code.to_s,
          'Committee' => 'DOCCM', 'Committee Long Descr' => 'Descr', 'Student ID' => '999999999' }
      end

      it 'creates a not required "Committee Member"' do
        expect(submission.committee_members.first.committee_role.name).to eq 'Committee Member'
        expect(submission.committee_members.first.is_required).to eq false
      end
    end
  end

  required_om_codes = ['UF', 'GF', 'GFU', 'GU', 'F']
  required_om_codes.each do |code|
    context "when inbound lionpath committee member has a role of #{code}" do
      let(:row) do
        { 'Access ID' => 'abc123', 'Last Name' => 'Tester', 'First Name' => 'Test', 'Role' => code.to_s,
          'Committee' => 'DOCCM', 'Committee Long Descr' => 'Descr', 'Student ID' => '999999999' }
      end

      it 'creates a required "Outside Member"' do
        expect(submission.committee_members.first.committee_role.name).to eq 'Outside Member'
        expect(submission.committee_members.first.is_required).to eq true
      end
    end
  end

  not_required_om_codes = ['UFN', 'UN', 'U', 'UFN', 'NF']
  not_required_om_codes.each do |code|
    context "when inbound lionpath committee member has a role of #{code}" do
      let(:row) do
        { 'Access ID' => 'abc123', 'Last Name' => 'Tester', 'First Name' => 'Test', 'Role' => code.to_s,
          'Committee' => 'DOCCM', 'Committee Long Descr' => 'Descr', 'Student ID' => '999999999' }
      end

      it 'creates a not required "Outside Member"' do
        expect(submission.committee_members.first.committee_role.name).to eq 'Outside Member'
        expect(submission.committee_members.first.is_required).to eq false
      end
    end
  end

  context "when inbound lionpath committee member has a role of S" do
    let(:row) do
      { 'Access ID' => 'abc123', 'Last Name' => 'Tester', 'First Name' => 'Test', 'Role' => 'S',
        'Committee' => 'DOCCM', 'Committee Long Descr' => 'Descr', 'Student ID' => '999999999' }
    end

    it 'creates a not required "Special Member"' do
      expect(submission.committee_members.first.committee_role.name).to eq 'Special Member'
      expect(submission.committee_members.first.is_required).to eq false
    end
  end

  context "when inbound lionpath committee member has a role of CISP" do
    let(:row) do
      { 'Access ID' => 'abc123', 'Last Name' => 'Tester', 'First Name' => 'Test', 'Role' => 'CISP',
        'Committee' => 'DOCCM', 'Committee Long Descr' => 'Descr', 'Student ID' => '999999999' }
    end

    it 'creates a required "Committee Chair/Co-Chair"' do
      expect(submission.committee_members.first.committee_role.name).to eq 'Committee Chair/Co-Chair'
      expect(submission.committee_members.first.is_required).to eq true
    end

    it 'creates a not required "Special Member"' do
      expect(submission.committee_members.second.committee_role.name).to eq 'Special Member'
      expect(submission.committee_members.second.is_required).to eq false
    end
  end

  chair_advisor_codes = ['HD', 'CD']
  chair_advisor_codes.each do |code|
    context "when inbound lionpath committee member has a role of #{code}" do
      let(:row) do
        { 'Access ID' => 'abc123', 'Last Name' => 'Tester', 'First Name' => 'Test', 'Role' => code.to_s,
          'Committee' => 'DOCCM', 'Committee Long Descr' => 'Descr', 'Student ID' => '999999999' }
      end

      it 'creates a required "Committee Chair/Co-Chair"' do
        expect(submission.committee_members.first.committee_role.name).to eq 'Committee Chair/Co-Chair'
        expect(submission.committee_members.first.is_required).to eq true
      end

      it 'creates a required "Dissertation Advisor/Co-Advisor"' do
        expect(submission.committee_members.second.committee_role.name).to eq 'Dissertation Advisor/Co-Advisor'
        expect(submission.committee_members.second.is_required).to eq true
      end
    end
  end

  chair_outside_codes = ['HF', 'HU']
  chair_outside_codes.each do |code|
    context "when inbound lionpath committee member has a role of #{code}" do
      let(:row) do
        { 'Access ID' => 'abc123', 'Last Name' => 'Tester', 'First Name' => 'Test', 'Role' => code.to_s,
          'Committee' => 'DOCCM', 'Committee Long Descr' => 'Descr', 'Student ID' => '999999999' }
      end

      it 'creates a required "Committee Chair/Co-Chair"' do
        expect(submission.committee_members.first.committee_role.name).to eq 'Committee Chair/Co-Chair'
        expect(submission.committee_members.first.is_required).to eq true
      end

      it 'creates a required "Outside Member"' do
        expect(submission.committee_members.second.committee_role.name).to eq 'Outside Member'
        expect(submission.committee_members.second.is_required).to eq true
      end
    end
  end

  context "when inbound lionpath committee member has a role of HM" do
    let(:row) do
      { 'Access ID' => 'abc123', 'Last Name' => 'Tester', 'First Name' => 'Test', 'Role' => 'HM',
        'Committee' => 'DOCCM', 'Committee Long Descr' => 'Descr', 'Student ID' => '999999999' }
    end

    it 'creates a required "Committee Chair/Co-Chair"' do
      expect(submission.committee_members.first.committee_role.name).to eq 'Committee Chair/Co-Chair'
      expect(submission.committee_members.first.is_required).to eq true
    end

    it 'creates a required "Committee Member"' do
      expect(submission.committee_members.second.committee_role.name).to eq 'Committee Member'
      expect(submission.committee_members.second.is_required).to eq true
    end
  end

  context "when inbound lionpath committee member has a role of CMSP" do
    let(:row) do
      { 'Access ID' => 'abc123', 'Last Name' => 'Tester', 'First Name' => 'Test', 'Role' => 'CMSP',
        'Committee' => 'DOCCM', 'Committee Long Descr' => 'Descr', 'Student ID' => '999999999' }
    end

    it 'creates a required "Committee Member"' do
      expect(submission.committee_members.first.committee_role.name).to eq 'Committee Member'
      expect(submission.committee_members.first.is_required).to eq true
    end

    it 'creates a not required "Special Member"' do
      expect(submission.committee_members.second.committee_role.name).to eq 'Special Member'
      expect(submission.committee_members.second.is_required).to eq false
    end
  end

  context "when inbound lionpath committee member has a role of MD" do
    let(:row) do
      { 'Access ID' => 'abc123', 'Last Name' => 'Tester', 'First Name' => 'Test', 'Role' => 'MD',
        'Committee' => 'DOCCM', 'Committee Long Descr' => 'Descr', 'Student ID' => '999999999' }
    end

    it 'creates a required "Committee Member"' do
      expect(submission.committee_members.first.committee_role.name).to eq 'Committee Member'
      expect(submission.committee_members.first.is_required).to eq true
    end

    it 'creates a not required "Dissertation Advisor/Co-Advisor"' do
      expect(submission.committee_members.second.committee_role.name).to eq 'Dissertation Advisor/Co-Advisor'
      expect(submission.committee_members.second.is_required).to eq false
    end
  end

  context "when inbound lionpath committee member has a role of SR" do
    let(:row) do
      { 'Access ID' => 'abc123', 'Last Name' => 'Tester', 'First Name' => 'Test', 'Role' => 'SR',
        'Committee' => 'DOCCM', 'Committee Long Descr' => 'Descr', 'Student ID' => '999999999' }
    end

    it 'creates a not required "Special Member"' do
      expect(submission.committee_members.first.committee_role.name).to eq 'Special Member'
      expect(submission.committee_members.first.is_required).to eq false
    end

    it 'creates a not required "Dissertation Advisor/Co-Advisor"' do
      expect(submission.committee_members.second.committee_role.name).to eq 'Dissertation Advisor/Co-Advisor'
      expect(submission.committee_members.second.is_required).to eq false
    end
  end
end
