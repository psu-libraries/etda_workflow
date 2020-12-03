require 'model_spec_helper'

RSpec.describe Lionpath::LionpathProgram do
  subject(:lionpath_program) { described_class.new }

  let!(:degree) { FactoryBot.create :degree, name: 'PHD' }

  let(:row_1) do
    {
        'ID' => 999999999, 'Last Name' => 'Tester', 'First Name' => 'Test', 'Exp Grad' => 2215,
        'Acadademic Plan' => 'BIOE_PHD', 'Transcript Descr' => 'Bioengineering (PHD)', 'Milestone Code' => nil,
        'Milestone Desc' => nil, 'Date Attempted' => nil, 'Exam Status' => nil, 'Alternate Email' => 'test@psu.edu',
        'Campus' => 'UP'
    }
  end

  let(:row_2) do
    {
        'ID' => 999999999, 'Last Name' => 'Tester', 'First Name' => 'Test', 'Exp Grad' => 2205,
        'Acadademic Plan' => 'BIOE_PHD', 'Transcript Descr' => 'Bioengineering (PHD)', 'Milestone Code' => nil,
        'Milestone Desc' => nil, 'Date Attempted' => nil, 'Exam Status' => nil, 'Alternate Email' => 'test@psu.edu',
        'Campus' => 'UP'
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
      expect(Author.first.alternate_email_address).to eq(row_1['Alternate Email'])
      expect(Author.first.first_name).to eq('testfirst')
      expect(Author.first.last_name).to eq('testlast')
      expect(Author.first.submissions.first.program.name).to eq(row_1['Transcript Descr'])
      expect(Author.first.submissions.first.program.code).to eq(row_1['Acadademic Plan'])
      expect(Author.first.submissions.first.program.is_active).to eq(true)
      expect(Author.first.submissions.first.program.lionpath_updated_at).to be_truthy
      expect(Author.first.submissions.first.degree.name).to eq(row_1['Acadademic Plan'].split('_')[1].to_s)
      expect(Author.first.submissions.first.year).to eq(2021)
      expect(Author.first.submissions.first.semester).to eq('Summer')
      expect(Author.first.submissions.first.campus).to eq('UP')
      expect(Author.first.submissions.first.status).to eq('collecting program information')
    end
  end

  context 'when author and program exist' do
    let!(:author) { FactoryBot.create :author, psu_idn: '999999999' }
    let!(:program) { FactoryBot.create :program, code: row_1['Acadademic Plan'] }

    it 'links to existing author and program' do
      lionpath_program.import(row_1)
      expect(Submission.first.program).to eq program
      expect(Submission.first.author).to eq author
    end
  end

  context 'when submission already exists' do
    let!(:author) { FactoryBot.create :author, psu_idn: '999999999' }
    let!(:program) { FactoryBot.create :program, code: row_1['Acadademic Plan'] }
    let!(:submission) { FactoryBot.create :submission, author: author, degree: degree }

    it 'updates the submission' do
      expect{ lionpath_program.import(row_1) }.to change{ Submission.count }.by 0
    end
  end

  context 'when program from lionpath is before 2021' do
    let!(:author) { FactoryBot.create :author, psu_idn: '999999999' }
    let!(:program) { FactoryBot.create :program, code: row_2['Acadademic Plan'] }

    it 'does not import the record' do
      expect{ lionpath_program.import(row_2) }.to change{ Submission.count }.by 0
    end
  end
end
