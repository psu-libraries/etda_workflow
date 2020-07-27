require 'presenters/presenters_spec_helper'

RSpec.describe Author::ProgramInformationView do
  let(:submission) { FactoryBot.create :submission, :collecting_program_information }
  let(:view) { described_class.new(submission) }

  context '#new_program_information_partial' do
    it 'returns the input form' do
      expect(view.new_program_information_partial).to eq('standard_program_information')
    end
  end

  context '#edit_program_information_partial' do
    it 'returns the input form' do
      expect(view.edit_program_information_partial).to eq('standard_program_information')
    end
  end
end
