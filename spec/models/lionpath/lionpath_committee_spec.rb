require 'model_spec_helper'

RSpec.describe Lionpath::LionpathCommittee do
  subject(:lionpath_committee) { described_class.new }

  let!(:author) { FactoryBot.create :author, psu_idn: '999999999' }
  let!(:submission) do
    FactoryBot.create :submission, author: author, degree: degree, status: 'collecting program information'
  end
  let!(:degree) { FactoryBot.create :degree, name: 'PHD', degree_type: degree_type }
  let!(:degree_type) { DegreeType.find_by(slug: 'dissertation') }
  let!(:committee_role) { FactoryBot.create :committee_role, code: 'C', name: 'Chair of Committee' }
  let(:row) do
    { 'Access ID' => 'abc123', 'Last Name' => 'Tester', 'First Name' => 'Test', 'Role' => 'C',
      'Committee' => 'DOCCM', 'Committee Long Descr' => 'Chair of Committee', 'Student ID' => '999999999' }
  end

  context "when author's submission has lionpath_upload_finished_at timestamp" do
    before do
      submission.update lionpath_upload_finished_at: DateTime.now
    end

    it 'does not import data' do
      expect { lionpath_committee.import(row) }.to change { submission.committee_members.count }.by 0
    end
  end

  context "when author's submission does not have lionpath_upload_finished_at timestamp" do
    it 'imports data' do
      expect { lionpath_committee.import(row) }.to change { submission.committee_members.count }.by 1
      expect(submission.committee_members.first.name).to eq 'Test Tester'
    end
  end

  context "when author has a dissertation submission" do
    let!(:submission_dissertation) { FactoryBot.create :submission }

    it 'does not affect dissertation committee' do
      expect { lionpath_committee.import(row) }.to change { submission_dissertation.committee_members.count }.by 0
    end
  end
end
