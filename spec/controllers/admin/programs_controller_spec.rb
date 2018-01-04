# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Admin::ProgramsController, type: :controller do
  describe '#index' do
    it 'shows all programs' do
      expect(get: admin_programs_path).to route_to(controller: 'admin/programs', action: 'index')
    end
  end
  describe '#edit' do
    let(:program) { FactoryBot.create(:program) }
    it 'edits an existing program' do
      expect(get: edit_admin_program_path(program.id)).to route_to(controller: 'admin/programs', action: 'edit', id: program.id.to_s)
    end
  end
  describe '#new' do
    it 'creates a program' do
      expect(get: new_admin_program_path).to route_to(controller: 'admin/programs', action: 'new')
    end
  end
end
