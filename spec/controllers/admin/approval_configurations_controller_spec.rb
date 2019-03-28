# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::ApprovalConfigurationsController, type: :controller do
  describe '#index' do
    it 'shows all degree types' do
      expect(get: admin_approval_configurations_path).to route_to(controller: 'admin/approval_configurations', action: 'index')
    end
  end

  describe '#edit' do
    let(:degree_type) { DegreeType.default }
    let(:approval_configuration) { FactoryBot.create(:approval_configuration, :degree_type) }

    it 'edits an existing author' do
      expect(get: edit_admin_approval_configuration_path(degree_type.id)).to route_to(controller: 'admin/approval_configurations', action: 'edit', id: degree_type.id.to_s)
    end
  end
end
