require 'model_spec_helper'

RSpec.describe Lionpath::LionpathCommittee do
  subject(:lionpath_committee) { described_class.new }

  let!(:author) { FactoryBot.create :author, psu_idn: '999999999' }
  let!(:submission) { FactoryBot.create :submission, author: author, degree: degree }
  let!(:degree) { FactoryBot.create :degree, name: 'PHD', degree_type: degree_type }
  let!(:degree_type) { DegreeType.find_by(slug: 'dissertation') }
  let(:row) do
    { 'Student ID' => '999999999' }
  end

  context "when author's submission already has a committee" do
    before do
      create_committee(submission)
    end

    it 'does not import data' do
      expect{ lionpath_committee.import(row) }.to change{ submission.committee_members.count }.by 0
    end
  end
end
