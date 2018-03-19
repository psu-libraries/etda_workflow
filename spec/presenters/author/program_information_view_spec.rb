require 'presenters/presenters_spec_helper'

RSpec.describe Author::ProgramInformationView do
  let(:submission) { FactoryBot.create :submission, :collecting_program_information }
  let(:view) { described_class.new(submission) }

  describe 'no lion path record' do
    context '#new_program_information_partial' do
      it 'returns the input form when there is no lion path record' do
        expect(view.new_program_information_partial).to eq('standard_program_information')
      end
    end
    context '#edit_program_information_partial' do
      it 'returns the input form when there is no lion _path_record' do
        expect(view.edit_program_information_partial).to eq('standard_program_information')
      end
    end
  end
  describe 'lion path record' do
    context '#new_program_information_partial' do
      it 'returns program information from lion_path' do
        allow(InboundLionPathRecord).to receive(:active?).and_return(true)
        expect(view.new_program_information_partial).to eq('lionpath_program_information')
      end
    end
    context '#edit_program_information_partial' do
      it 'returns the input form when there is no lion _path_record' do
        allow_any_instance_of(Submission).to receive(:using_lionpath?).and_return(true)
        expect(view.edit_program_information_partial).to eq('lionpath_program_information')
      end
    end
  end
end
