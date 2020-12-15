require 'model_spec_helper'

RSpec.describe Lionpath::LionpathCsvImporter do
  subject(:lionpath_csv_importer) { described_class.new }

  describe '#import' do
    context 'when current_partner is not graduate' do
      it 'raises an error', milsch: true, honors: true do
        skip 'non graduate' if current_partner.graduate?

        expect { lionpath_csv_importer.import }.to raise_error(Lionpath::LionpathCsvImporter::InvalidPartner)
      end
    end
  end

  describe 'parsing of csvs' do
    before do
      allow_any_instance_of(described_class).to receive(:lionpath_csv_loc).and_return(fixture_location)
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
      let!(:submission) do
        FactoryBot.create :submission, degree: degree, author: author,
                                       year: 2021
      end
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
    let!(:degree) { FactoryBot.create :degree, degree_type: DegreeType.first }
    let!(:program_head_role) { CommitteeRole.find_by(name: 'Program Head/Chair', degree_type: degree.degree_type) }
    let!(:program) { FactoryBot.create :program }
    let!(:program_chair) { FactoryBot.create :program_chair, program: program, campus: 'UP' }

    context 'when submission is before 2021' do
      let!(:submission) do
        FactoryBot.create :submission, year: 2020,
                                       degree: degree, program: program, campus: 'UP'
      end
      let!(:committee_member) { FactoryBot.create :committee_member, submission: submission }

      it 'does not get a chair' do
        expect { lionpath_csv_importer.send(:assign_chairs) }.to change(CommitteeMember, :count).by 0
      end
    end

    context 'when submission already has a program chair' do
      let!(:submission) do
        FactoryBot.create :submission, year: 2021,
                                       degree: degree, program: program, campus: 'UP'
      end
      let!(:program_head_member) do
        FactoryBot.create :committee_member, committee_role: program_head_role,
                                             submission: submission
      end
      let!(:committee_member) { FactoryBot.create :committee_member, submission: submission }

      it "updates pre-existing program chair in submissions' committee" do
        expect { lionpath_csv_importer.send(:assign_chairs) }.to change(CommitteeMember, :count).by 0
        expect(Submission.find(submission.id).committee_members.first.access_id).to eq program_chair.access_id
      end
    end

    context "when submission doesn't have a program chair yet" do
      let!(:submission) do
        FactoryBot.create :submission, year: 2021,
                                       degree: degree, program: program, campus: 'UP'
      end
      let!(:committee_member) { FactoryBot.create :committee_member, submission: submission }

      it "adds program chair to submissions' committee" do
        expect { lionpath_csv_importer.send(:assign_chairs) }.to change(CommitteeMember, :count).by 1
        expect(Submission.find(submission.id).committee_members.second.access_id).to eq program_chair.access_id
        expect(Submission.find(submission.id).committee_members.second.is_voting).to eq false
        expect(Submission.find(submission.id).committee_members.second.is_required).to eq true
      end
    end
  end
end
