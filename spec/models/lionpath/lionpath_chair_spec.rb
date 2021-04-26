require 'model_spec_helper'

RSpec.describe Lionpath::LionpathChair do
  subject(:lionpath_chair) { described_class.new }

  let!(:program) { FactoryBot.create :program, code: 'ABC_XYZ' }

  context 'when no Professor In Charge (PIC) is present in CSV' do
    let(:row) do
      {
        'Chair Access ID' => 'ABC123', 'Acad Plan' => 'ABC_XYZ', 'Acad Prog' => 'GREM', 'Campus' => 'UP',
        'Chair Last Name' => 'New Tester', 'Chair First Name' => 'New Test', 'Chair Phone' => '18141234567',
        'Chair Phone Type' => 'UNIV', 'Chair Univ Email' => 'ABC123@psu.edu', 'ROLE' => nil,
        'DGS/PIC Access ID' => nil, 'DGS/PIC Last Name' => nil, 'DGS/PIC First Name' => nil,
        'DGS/PIC Phone' => nil, 'DGS/PIC Phone Type' => nil, 'DGS/PIC Univ Email' => nil
      }
    end

    context 'when program chair already exists' do
      let!(:program_chair) { FactoryBot.create :program_chair, program: program, access_id: 'abc123' }

      it 'updates existing program chair' do
        expect { lionpath_chair.import(row) }.to change(ProgramChair, :count).by 0
        expect(Program.find(program.id).program_chairs.first.first_name).to eq 'New Test'
        expect(Program.find(program.id).program_chairs.first.last_name).to eq 'New Tester'
        expect(Program.find(program.id).program_chairs.first.phone).to eq 18141234567
        expect(Program.find(program.id).program_chairs.first.access_id).to eq 'abc123'
        expect(Program.find(program.id).program_chairs.first.email).to eq 'abc123@psu.edu'
        expect(Program.find(program.id).program_chairs.first.campus).to eq 'UP'
      end
    end

    context 'when program chair does not exist' do
      it 'creates new program chair' do
        expect { lionpath_chair.import(row) }.to change(ProgramChair, :count).by 1
        expect(Program.find(program.id).program_chairs.first.first_name).to eq 'New Test'
        expect(Program.find(program.id).program_chairs.first.last_name).to eq 'New Tester'
        expect(Program.find(program.id).program_chairs.first.phone).to eq 18141234567
        expect(Program.find(program.id).program_chairs.first.access_id).to eq 'abc123'
        expect(Program.find(program.id).program_chairs.first.email).to eq 'abc123@psu.edu'
        expect(Program.find(program.id).program_chairs.first.campus).to eq 'UP'
      end
    end

    context 'when program does not exist' do
      let(:row_2) do
        {
          'Access ID' => 'ABC123', 'Acad Plan' => 'TYU_GHJ', 'Acad Prog' => 'GREM', 'Campus' => 'UP',
          'Last Name' => 'New Tester', 'First Name' => 'New Test', 'Phone' => '18141234567', 'Phone Type' => 'UNIV',
          'Univ Email' => 'ABC123@psu.edu'
        }
      end

      it 'does nothing' do
        expect { lionpath_chair.import(row_2) }.to change(ProgramChair, :count).by 0
        expect(ProgramChair.count).to eq 0
      end
    end

    context 'when program exists and has more than one campus' do
      let!(:program_chair) { FactoryBot.create :program_chair, program: program, access_id: 'abc123', campus: 'AB' }

      it 'adds another program chair' do
        expect { lionpath_chair.import(row) }.to change(ProgramChair, :count).by 1
        expect(ProgramChair.count).to eq 2
        expect(Program.find(program.id).program_chairs.first.campus).to eq 'AB'
        expect(Program.find(program.id).program_chairs.first.first_name).to eq 'Test'
        expect(Program.find(program.id).program_chairs.second.campus).to eq 'UP'
        expect(Program.find(program.id).program_chairs.second.first_name).to eq 'New Test'
      end
    end
  end

  context 'when Professor In Charge (PIC) and corresponding Department Head is present in CSV' do
    let(:row) do
      {
        'Chair Access ID' => 'ABC123', 'Acad Plan' => 'ABC_XYZ', 'Acad Prog' => 'GREM', 'Campus' => 'UP',
        'Chair Last Name' => 'New Tester', 'Chair First Name' => 'New Test', 'Chair Phone' => '18141234567',
        'Chair Phone Type' => 'UNIV', 'Chair Univ Email' => 'ABC123@psu.edu', 'ROLE' => 'DPIC',
        'DGS/PIC Access ID' => 'DEF456', 'DGS/PIC Last Name' => 'PIC Tester', 'DGS/PIC First Name' => 'PIC Test',
        'DGS/PIC Phone' => '18147654321', 'DGS/PIC Phone Type' => 'UNIV', 'DGS/PIC Univ Email' => 'DEF456@psu.edu'
      }
    end

    context 'when PIC  and Department Head already exist' do
      let!(:program_chair1) do
        FactoryBot.create :program_chair, program: program, access_id: 'abc123', role: 'Department Head'
      end
      let!(:program_chair2) do
        FactoryBot.create :program_chair, program: program, access_id: 'def123', role: 'Professor in Charge'
      end

      it 'updates existing PIC' do
        expect { lionpath_chair.import(row) }.to change(ProgramChair, :count).by 0
        program_chair2.reload
        expect(program_chair2.first_name).to eq 'PIC Test'
        expect(program_chair2.last_name).to eq 'PIC Tester'
        expect(program_chair2.phone).to eq 18147654321
        expect(program_chair2.access_id).to eq 'def456'
        expect(program_chair2.email).to eq 'def456@psu.edu'
        expect(program_chair2.campus).to eq 'UP'
      end
    end

    context 'when PIC does not exist but Department Head does' do
      let!(:program_chair1) do
        FactoryBot.create :program_chair, program: program, access_id: 'abc123', role: 'Department Head'
      end

      it 'creates new PIC chair' do
        expect { lionpath_chair.import(row) }.to change(ProgramChair, :count).by 1
        expect(Program.find(program.id).program_chairs.second.first_name).to eq 'PIC Test'
        expect(Program.find(program.id).program_chairs.second.last_name).to eq 'PIC Tester'
        expect(Program.find(program.id).program_chairs.second.phone).to eq 18147654321
        expect(Program.find(program.id).program_chairs.second.access_id).to eq 'def456'
        expect(Program.find(program.id).program_chairs.second.email).to eq 'def456@psu.edu'
        expect(Program.find(program.id).program_chairs.second.campus).to eq 'UP'
      end
    end

    context 'when neither PIC or Department Head exists' do
      it 'creates new PIC chair' do
        expect { lionpath_chair.import(row) }.to change(ProgramChair, :count).by 2
        expect(Program.find(program.id).program_chairs.first.first_name).to eq 'New Test'
        expect(Program.find(program.id).program_chairs.first.last_name).to eq 'New Tester'
        expect(Program.find(program.id).program_chairs.first.phone).to eq 18141234567
        expect(Program.find(program.id).program_chairs.first.access_id).to eq 'abc123'
        expect(Program.find(program.id).program_chairs.first.email).to eq 'abc123@psu.edu'
        expect(Program.find(program.id).program_chairs.first.campus).to eq 'UP'
        expect(Program.find(program.id).program_chairs.second.first_name).to eq 'PIC Test'
        expect(Program.find(program.id).program_chairs.second.last_name).to eq 'PIC Tester'
        expect(Program.find(program.id).program_chairs.second.phone).to eq 18147654321
        expect(Program.find(program.id).program_chairs.second.access_id).to eq 'def456'
        expect(Program.find(program.id).program_chairs.second.email).to eq 'def456@psu.edu'
        expect(Program.find(program.id).program_chairs.second.campus).to eq 'UP'
      end
    end
  end
end
