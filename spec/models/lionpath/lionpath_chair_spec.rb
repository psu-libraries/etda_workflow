require 'model_spec_helper'

RSpec.describe Lionpath::LionpathChair do
  subject(:lionpath_chair) { described_class.new }
  let!(:program) { FactoryBot.create :program, code: 'ABC_XYZ' }
  let(:row) do
    {
      'Access ID' => 'ABC123', 'Acad Plan' => 'ABC_XYZ', 'Acad Prog' => 'GREM', 'Campus' => 'UP',
      'Last Name' => 'New Tester', 'First Name' => 'New Test', 'Phone' => '18141234567', 'Phone Type' => 'UNIV',
      'Univ Email' => 'ABC123@psu.edu'
    }
  end

  context 'when program chair already exists' do
    let!(:program_chair) { FactoryBot.create :program_chair, program: program, access_id: 'abc123' }

    it 'updates existing program chair' do
      expect { lionpath_chair.import(row) }.to change { ProgramChair.count }.by 0
      expect(Program.find(program.id).program_chair.first_name).to eq 'New Test'
      expect(Program.find(program.id).program_chair.last_name).to eq 'New Tester'
      expect(Program.find(program.id).program_chair.phone).to eq 18141234567
      expect(Program.find(program.id).program_chair.access_id).to eq 'abc123'
      expect(Program.find(program.id).program_chair.email).to eq 'abc123@psu.edu'
      expect(Program.find(program.id).program_chair.campus).to eq 'UP'
    end
  end

  context 'when program chair does not exist' do
    it 'it creates new program chair' do
      expect { lionpath_chair.import(row) }.to change { ProgramChair.count }.by 1
      expect(Program.find(program.id).program_chair.first_name).to eq 'New Test'
      expect(Program.find(program.id).program_chair.last_name).to eq 'New Tester'
      expect(Program.find(program.id).program_chair.phone).to eq 18141234567
      expect(Program.find(program.id).program_chair.access_id).to eq 'abc123'
      expect(Program.find(program.id).program_chair.email).to eq 'abc123@psu.edu'
      expect(Program.find(program.id).program_chair.campus).to eq 'UP'
    end
  end

  context 'when program does not exit' do
    let(:row_2) do
      {
          'Access ID' => 'ABC123', 'Acad Plan' => 'TYU_GHJ', 'Acad Prog' => 'GREM', 'Campus' => 'UP',
          'Last Name' => 'New Tester', 'First Name' => 'New Test', 'Phone' => '18141234567', 'Phone Type' => 'UNIV',
          'Univ Email' => 'ABC123@psu.edu'
      }
    end
    it 'does nothing' do
      expect { lionpath_chair.import(row_2) }.to change { ProgramChair.count }.by 0
      expect(ProgramChair.count).to eq 0
    end
  end
end
