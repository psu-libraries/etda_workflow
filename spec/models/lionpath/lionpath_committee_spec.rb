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

  context "when author's submission is during Spring 2021" do
    before do
      submission.update year: 2021, semester: 'Spring'
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
        FactoryBot.create :committee_member, committee_role: committee_role,
                                             name: 'wrong', access_id: 'abc123', submission: submission
      end

      it 'updates that committee member record' do
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
end
