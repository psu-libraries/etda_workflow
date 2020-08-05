require 'model_spec_helper'

RSpec.describe Lionpath::LionpathProgram do
  subject(:lionpath_program) { described_class.new }

  let!(:degree) { FactoryBot.create :degree, name: 'PHD' }

  let(:row) do
    {
      'ID' => 999999999, 'Last Name' => 'Tester', 'First Name' => 'Test', 'Exp Grad' => 2215,
      'Acadademic Plan' => 'BIOE_PHD', 'Transcript Descr' => 'Bioengineering (PHD)', 'Milestone Code' => nil,
      'Milestone Desc' => nil, 'Date Attempted' => nil, 'Exam Status' => nil, 'Alternate Email' => 'test@psu.edu'
    }
  end

  context 'when no author or program exists' do
    before do
      lionpath_program.import(row)
    end

    it 'imports academic plan and creates a new author and program record' do
      expect(Author.count).to eq 1
      expect(Program.count).to eq 1
    end

    it 'populates proper attributes' do
      expect(Author.first.psu_idn).to eq(row['ID'].to_s)
      expect(Author.first.alternate_email_address).to eq(row['Alternate Email'])
      expect(Author.first.first_name).to eq('testfirst')
      expect(Author.first.last_name).to eq('testlast')
      expect(Author.first.submissions.first.program.name).to eq(row['Transcript Descr'])
      expect(Author.first.submissions.first.program.code).to eq(row['Acadademic Plan'])
      expect(Author.first.submissions.first.program.is_active).to eq(false)
      expect(Author.first.submissions.first.program.lionpath_uploaded_at).to be_truthy
      expect(Author.first.submissions.first.degree.name).to eq(row['Acadademic Plan'].split('_')[1].to_s)
      expect(Author.first.submissions.first.year).to eq(2021)
      expect(Author.first.submissions.first.semester).to eq('Summer')
    end
  end

  context 'when author and program exist' do
    let!(:author) { FactoryBot.create :author, psu_idn: '999999999' }
    let!(:program) { FactoryBot.create :program, code: row['Acadademic Plan'] }

    it 'links to existing author and program' do
      lionpath_program.import(row)
      expect(Submission.first.program).to eq program
      expect(Submission.first.author).to eq author
    end
  end
end
