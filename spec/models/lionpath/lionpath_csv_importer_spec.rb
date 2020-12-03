require 'model_spec_helper'

RSpec.describe Lionpath::LionpathCsvImporter do
  subject(:lionpath_csv_importer) { described_class.new }

  describe 'parsing of csvs' do
    before do
      allow(lionpath_csv_importer).to receive(:`).and_return(true)
      allow(lionpath_csv_importer).to receive(:lionpath_csv_loc).and_return(fixture_location)
    end

    context 'when lionpath_resource is LionpathProgram' do
      let(:fixture_location) { "#{Rails.root}/spec/fixtures/lionpath/lionpath_program.csv" }
      let!(:author_1) { FactoryBot.create :author, psu_idn: '912345678' }
      let!(:author_2) { FactoryBot.create :author, psu_idn: '912345679' }
      let!(:author_3) { FactoryBot.create :author, psu_idn: '912345680' }
      let!(:author_4) { FactoryBot.create :author, psu_idn: '912345681' }
      let!(:author_5) { FactoryBot.create :author, psu_idn: '912345682' }
      let!(:degree_phd) { FactoryBot.create :degree, name: 'PHD', degree_type: DegreeType.first }
      let!(:degree_ms) { FactoryBot.create :degree, name: 'MS', degree_type: DegreeType.second }

      it 'imports lionpath program data' do
        lionpath_csv_importer.send(:parse_csv, Lionpath::LionpathProgram.new)
        expect(Submission.count).to eq 5
        expect(Program.count).to eq 5
        expect(Author.find(author_1.id).submissions.first.program.name).to eq 'Bioengineering (PHD)'
        expect(Author.find(author_1.id).submissions.first.degree.degree_type.slug).to eq 'dissertation'
        expect(Author.find(author_3.id).submissions.first.degree.degree_type.slug).to eq 'master_thesis'
      end
    end

    context 'when lionpath_resource is LionpathChair' do
      let(:fixture_location) { "#{Rails.root}/spec/fixtures/lionpath/lionpath_chair.csv" }
      let!(:program_1) { FactoryBot.create :program, code: 'SDS_MS' }
      let!(:program_2) { FactoryBot.create :program, code: 'NUTR_MS' }
      let!(:program_3) { FactoryBot.create :program, code: 'NUTR_PHD' }
      let!(:program_4) { FactoryBot.create :program, code: 'NEURS_MS' }

      it 'imports lionpath chair data' do
        lionpath_csv_importer.send(:parse_csv, Lionpath::LionpathChair.new)
        expect(ProgramChair.count).to eq 5
        expect(Program.find(program_1.id).program_chairs.first.last_name).to eq 'Tester1'
      end
    end

    context 'when lionpath_resource is LionpathCommittee' do
      let(:fixture_location) { "#{Rails.root}/spec/fixtures/lionpath/lionpath_committee.csv" }
      let!(:author) { FactoryBot.create :author, psu_idn: '999999999' }
      let!(:submission) { FactoryBot.create :submission, degree: degree, author: author,
                                                  created_at: DateTime.strptime('2021-01-02', '%Y-%m-%d') }
      let!(:degree) { FactoryBot.create :degree, degree_type: DegreeType.first }
      before do
        FactoryBot.create :committee_role, code: 'CHMJ'
        FactoryBot.create :committee_role, code: 'CMMJ'
        FactoryBot.create :committee_role, code: 'UF'
        FactoryBot.create :committee_role, code: 'MD'
      end

      it 'imports lionpath committee data' do
        lionpath_csv_importer.send(:parse_csv, Lionpath::LionpathCommittee.new)
        expect(CommitteeMember.count).to eq 5
        expect(author.submissions.first.committee_members.count).to eq 5
        expect(author.submissions.first.committee_members.first.name).to eq 'Test1 Tester1'
      end
    end
  end

  describe '#assign_chairs' do
    context 'when submission is before 2021' do

    end

    context 'when submission has no committee' do

    end

    context 'when submission already has a program chair' do
      let!(:degree) { FactoryBot.create :degree, degree_type: DegreeType.first }
      let!(:submission) { FactoryBot.create :submission, created_at: DateTime.strptime('2021-01-02', '%Y-%m-%d'),
                                            degree: degree }
      let!(:program_head_role) { FactoryBot.create :committee_role, name: 'Program Head/Chair',
                                                   degree_type: degree.degree_type }
      let!(:program_head_member) { FactoryBot.create :committee_member, committee_role: program_head_role,
                                                            submission: submission }
      let!(:committee_member) { FactoryBot.create :committee_member, submission: submission }

    end

    context "when submission doesn't have a program chair yet" do
      let!(:degree) { FactoryBot.create :degree, degree_type: DegreeType.first }
      let!(:submission) { FactoryBot.create :submission, created_at: DateTime.strptime('2021-01-02', '%Y-%m-%d'),
                                                   degree: degree, program: program, campus: 'UP' }
      let!(:program_head_role) { FactoryBot.create :committee_role, name: 'Program Head/Chair',
                                                          degree_type: degree.degree_type }
      let!(:committee_member) { FactoryBot.create :committee_member, submission: submission }
      let!(:program) { FactoryBot.create :program }
      let!(:program_chair) { FactoryBot.create :program_chair, program: program, campus: 'UP' }
      it "adds program chair to submissions' committee" do
        expect{ lionpath_csv_importer.send(:assign_chairs) }.to change{ CommitteeMember.count }.by 1
      end
    end
  end
end
