require 'model_spec_helper'

RSpec.describe Lionpath::LionpathCommittee do
  subject(:lionpath_committee) { described_class.new }

  let!(:author) { FactoryBot.create :author, psu_idn: '999999999', access_id: 'def123' }
  let!(:submission) do
    FactoryBot.create :submission, author: author, degree: degree,
                                   status: 'collecting program information', lionpath_updated_at: DateTime.now
  end
  let!(:degree) { FactoryBot.create :degree, name: 'PHD', degree_type: degree_type }
  let!(:degree_type) { DegreeType.find_by(slug: 'dissertation') }
  let!(:committee_role) { FactoryBot.create :committee_role, code: 'C', name: 'Chair of Committee' }
  let(:row) do
    { 'Access ID' => 'abc123', 'Last Name' => 'Tester', 'First Name' => 'Test', 'Role' => 'C',
      'Committee' => 'DOCCM', 'Committee Long Descr' => 'Chair of Committee', 'Student ID' => '999999999',
      'Student Campus ID' => 'def123', 'Suprvsr Nbr' => '932352541' }
  end

  context "when author's submission's year is before 2021" do
    before do
      submission.update year: 2020
    end

    it 'does not import data' do
      expect { lionpath_committee.import(row) }.to change { submission.committee_members.count }.by 0
    end
  end

  context "when author's submission does not have a lionpath_updated_at timestamp" do
    before do
      submission.update lionpath_updated_at: nil
    end

    it 'does not import data' do
      expect { lionpath_committee.import(row) }.to change { submission.committee_members.count }.by 0
    end
  end

  context "when author does not have a dissertation submission" do
    before do
      degree.update degree_type: DegreeType.find_by(slug: 'master_thesis')
    end

    it 'does not import data' do
      expect { lionpath_committee.import(row) }.to change { submission.committee_members.count }.by 0
    end
  end

  context "when author's submission is beyond Spring 2021" do
    before do
      submission.update year: 2021, semester: 'Summer'
    end

    it 'imports data' do
      expect { lionpath_committee.import(row) }.to change { submission.committee_members.count }.by 1
    end

    context 'when submission already has the committee member from the lionpath record' do
      let!(:committee_member) do
        FactoryBot.create :committee_member, committee_role: committee_role, name: 'wrong',
                                             access_id: 'abc123', submission: submission, email: 'abc123@psu.edu'
      end

      it 'updates that committee member record (does not update email)' do
        expect { lionpath_committee.import(row) }.to change { submission.committee_members.count }.by 0
        expect(CommitteeMember.find(committee_member.id).name).to eq 'Test Tester'
        expect(CommitteeMember.find(committee_member.id).committee_role).to eq committee_role
        expect(CommitteeMember.find(committee_member.id).email).to eq 'abc123@psu.edu'
      end
    end

    context 'when submission does not have the committee member from the lionpath record' do
      it 'creates a committee member record' do
        expect { lionpath_committee.import(row) }.to change { submission.committee_members.count }.by 1
        expect(submission.committee_members.first.name).to eq 'Test Tester'
        expect(submission.committee_members.first.committee_role).to eq committee_role
        expect(submission.committee_members.first.email).to eq 'abc123@psu.edu'
      end
    end
  end

  context 'when author has two dissertations and one is not from lionpath' do
    let!(:submission_2) do
      FactoryBot.create :submission, author: author, degree: degree,
                                     status: 'collecting program information'
    end

    it 'imports the committee for the lionpath dissertation' do
      expect { lionpath_committee.import(row) }.to change { submission.committee_members.count }.by 1
      submission_2.reload
      expect(submission_2.committee_members.count).to eq 0
    end
  end

  context 'when committee member is external to PSU' do
    let!(:committee_role2) { FactoryBot.create :committee_role, code: 'S', name: 'Special Member' }
    let(:row2) do
      { 'Access ID' => 'mgc25', 'Last Name' => 'Committee', 'First Name' => 'Member', 'Role' => 'S',
        'Committee' => 'DOCCM', 'Committee Long Descr' => 'Special Member', 'Student ID' => '999999999',
        'Student Campus ID' => 'def123', 'Suprvsr Nbr' => '932352541' }
    end

    context 'when the committee member does not yet exist in the db' do
      it 'imports the record' do
        expect { lionpath_committee.import(row2) }.to change { submission.committee_members.count }.by 1
        expect(submission.committee_members.last.access_id).to eq 'mgc25'
        expect(submission.committee_members.last.external_to_psu_id).to eq 'mgc25'
      end
    end

    context 'when the committee member already exists in the db' do
      let!(:committee_member) do
        FactoryBot.create :committee_member, access_id: 'mgc25', email: 'mgc25@psu.edu', name: 'Member Committee',
                                             committee_role: committee_role2, submission: submission
      end

      context 'when the committee member in the db does not have an external_to_psu_id' do
        it 'just updates the is_external_to_psu field' do
          expect { lionpath_committee.import(row2) }.to change { submission.committee_members.count }.by 0
          committee_member.reload
          expect(committee_member.external_to_psu_id).to eq 'mgc25'
          expect(committee_member.email).to eq 'mgc25@psu.edu'
        end
      end

      context 'when the committee member has been edited' do
        it 'does not create a record or update anything' do
          committee_member.update(name: "Test Tester", email: 'tester@email.com', committee_role: committee_role2,
                                  access_id: nil, external_to_psu_id: 'mgc25')
          expect { lionpath_committee.import(row2) }.to change { submission.committee_members.count }.by 0
          committee_member.reload
          expect(committee_member.email).to eq 'tester@email.com'
        end
      end
    end
  end
end
