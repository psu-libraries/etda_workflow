require 'model_spec_helper'

RSpec.describe Lionpath::LionpathProgram do
  subject(:lionpath_program) { described_class.new }

  let!(:degree) { FactoryBot.create :degree, name: 'PHD' }
  let!(:degree_ms) { FactoryBot.create :degree, name: 'MS' }

  let(:row_1) do
    {
      'ID' => 999999999, 'Last Name' => 'Tester', 'First Name' => 'Test', 'Campus ID' => 'xxb13', 'Exp Grad' => 2215,
      'Acadademic Plan' => 'BIOE_PHD', 'Degree' => 'PHD', 'Transcript Descr' => 'Bioengineering (PHD)',
      'Milestone Code' => nil, 'Milestone Desc' => nil, 'Date Attempted' => nil, 'Exam Status' => nil,
      'Alternate Email' => 'test@psu.edu', 'Campus' => 'UP', 'Acad Prog' => 'GREN', 'ChkoutStat' => 'EG'
    }
  end

  let(:row_2) do
    {
      'ID' => 999999999, 'Last Name' => 'Tester', 'First Name' => 'Test', 'Campus ID' => 'xxb13', 'Exp Grad' => 2205,
      'Acadademic Plan' => 'BIOE_PHD', 'Degree' => 'PHD', 'Transcript Descr' => 'Bioengineering (PHD)',
      'Milestone Code' => nil, 'Milestone Desc' => nil, 'Date Attempted' => nil, 'Exam Status' => nil,
      'Alternate Email' => 'test@psu.edu', 'Campus' => 'UP', 'Acad Prog' => 'GREN', 'ChkoutStat' => 'EG'
    }
  end

  let(:row_3) do
    {
      'ID' => 999999999, 'Last Name' => 'Tester', 'First Name' => 'Test', 'Campus ID' => 'xxb13', 'Exp Grad' => 2211,
      'Acadademic Plan' => 'BIOE_MS', 'Degree' => 'MS', 'Transcript Descr' => 'Bioengineering (PHD)',
      'Milestone Code' => nil, 'Milestone Desc' => nil, 'Date Attempted' => nil, 'Exam Status' => nil,
      'Alternate Email' => 'test@psu.edu', 'Campus' => 'UP', 'Acad Prog' => 'GREN', 'ChkoutStat' => 'EG'
    }
  end

  context 'when no author or program exists' do
    before do
      lionpath_program.import(row_1)
    end

    it 'imports academic plan and creates a new author and program record' do
      expect(Author.count).to eq 1
      expect(Program.count).to eq 1
    end

    it 'populates proper attributes' do
      expect(Author.first.psu_idn).to eq(row_1['ID'].to_s)
      expect(Author.first.psu_email_address).to eq("#{row_1['Campus ID'].downcase}@psu.edu")
      expect(Author.first.alternate_email_address).to eq(row_1['Alternate Email'])
      expect(Author.first.first_name).to eq('testfirst')
      expect(Author.first.last_name).to eq('testlast')
      expect(Author.first.submissions.first.program.name).to eq(row_1['Transcript Descr'])
      expect(Author.first.submissions.first.program.code).to eq(row_1['Acadademic Plan'])
      expect(Author.first.submissions.first.program.is_active).to eq(true)
      expect(Author.first.submissions.first.program.lionpath_updated_at).to be_truthy
      expect(Author.first.submissions.first.lionpath_updated_at).to be_truthy
      expect(Author.first.submissions.first.degree.name).to eq(row_1['Acadademic Plan'].split('_')[1].to_s)
      expect(Author.first.submissions.first.lionpath_year).to eq(2021)
      expect(Author.first.submissions.first.lionpath_semester).to eq('Summer')
      expect(Author.first.submissions.first.campus).to eq('UP')
      expect(Author.first.submissions.first.status).to eq('collecting program information')
      expect(Author.first.submissions.first.academic_program).to eq('EN')
      expect(Author.first.submissions.first.degree_checkout_status).to eq('EG')
    end
  end

  context 'when author and program exist' do
    let!(:author) { FactoryBot.create :author, psu_idn: '999999999', access_id: 'xxb13' }
    let!(:program) { FactoryBot.create :program, code: row_1['Acadademic Plan'] }

    it 'links to existing author and program' do
      expect { lionpath_program.import(row_1) }.to change(Author, :count).by 0
      expect(Submission.first.program).to eq program
      expect(Submission.first.author).to eq author
    end
  end

  context 'when submission already exists' do
    let!(:author) { FactoryBot.create :author, psu_idn: '999999999', access_id: 'xxb13' }
    let!(:program) { FactoryBot.create :program, code: row_1['Acadademic Plan'] }
    let!(:submission) { FactoryBot.create :submission, author: author, degree: degree, program: program }

    it 'updates the submission' do
      expect { lionpath_program.import(row_1) }.to change(Submission, :count).by 0
      expect(Author.first.submissions.first.lionpath_updated_at).to be_truthy
      expect(Author.first.submissions.first.degree.name).to eq(row_1['Acadademic Plan'].split('_')[1].to_s)
      expect(Author.first.submissions.first.lionpath_year).to eq(2021)
      expect(Author.first.submissions.first.lionpath_semester).to eq('Summer')
      expect(Author.first.submissions.first.campus).to eq('UP')
    end

    context 'when submission is already beyond_waiting_for_final_submission_response_rejected?' do
      it 'does not update program info' do
        submission.update status: 'waiting for publication release'
        submission.reload
        expect { lionpath_program.import(row_1) }.not_to(change { Submission.find(submission.id).lionpath_updated_at })
        expect(Author.first.submissions.first.degree.name).to eq submission.degree.name
        expect(Author.first.submissions.first.lionpath_year).to eq submission.lionpath_year
        expect(Author.first.submissions.first.lionpath_semester).to eq submission.lionpath_semester
        expect(Author.first.submissions.first.campus).to eq submission.campus
      end
    end
  end

  context 'when program from lionpath is before 2021' do
    let!(:author) { FactoryBot.create :author, psu_idn: '999999999', access_id: 'xxb13' }
    let!(:program) { FactoryBot.create :program, code: row_2['Acadademic Plan'] }

    it 'does not import the record' do
      expect { lionpath_program.import(row_2) }.to change(Submission, :count).by 0
    end
  end

  context 'when program from lionpath is during Spring 2021' do
    let!(:author) { FactoryBot.create :author, psu_idn: '999999999', access_id: 'xxb13' }
    let!(:program) { FactoryBot.create :program, code: row_3['Acadademic Plan'] }

    context 'when no other Spring 2021 submission exists' do
      it 'imports and creates new record' do
        expect { lionpath_program.import(row_3) }.to change(Submission, :count).by 1
      end
    end

    context 'when another Spring 2021 submission exists that was not imported from LionPATH' do
      let(:sp2021_sub) { FactoryBot.create :submission, semester: 'Spring', year: 2021 }

      it 'does not import the record' do
        allow(Semester).to receive(:current).and_return "2021 Spring"
        author.submissions << sp2021_sub
        author.reload
        expect { lionpath_program.import(row_3) }.to change(Submission, :count).by 0
      end
    end

    context 'when another Spring 2021 submission exists that was imported from LionPATH' do
      let(:sp2021_sub) do
        FactoryBot.create :submission, semester: 'Spring', program: program, degree: degree_ms,
                                       year: 2021, lionpath_updated_at: DateTime.now
      end

      context 'when that submission is the same record that is being imported' do
        it 'updates existing record' do
          author.submissions << sp2021_sub
          author.reload
          expect { lionpath_program.import(row_3) }.to change(Submission, :count).by 0
          sp2021_sub.reload
          expect(sp2021_sub.program.code).to eq row_3["Acadademic Plan"]
        end
      end

      context 'when that submission is not the same record that is being imported' do
        it 'imports and creates new record' do
          sp2021_sub.program.update code: 'XYZ'
          author.submissions << sp2021_sub
          author.reload
          expect { lionpath_program.import(row_3) }.to change(Submission, :count).by 1
        end
      end
    end
  end
end
