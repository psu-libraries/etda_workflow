require 'model_spec_helper'

RSpec.describe Lionpath::LionpathProgram do
  subject(:lionpath_program) { described_class.new }

  let(:row) do
    {
      'ID' => 123456789, 'Last Name' => 'Tester', 'First Name' => 'Test', 'Exp Grad' => 2215,
      'Acadademic Plan' => 'BIOE_PHD', 'Milestone Code' => nil, 'Milestone Desc' => nil,
      'Date Attempted' => nil, 'Exam Status' => nil, 'Alternate Email' => 'test@psu.edu'
    }
  end

  context 'when no author or program exists' do
    it 'imports academic plan and creates a new author and program record' do
      expect(Author.count).to eq 0
      expect(Program.count).to eq 0
      lionpath_program.import(row)
      expect(Author.count).to eq 1
      expect(Program.count).to eq 1
    end
  end
end
