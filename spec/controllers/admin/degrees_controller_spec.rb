# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Admin::DegreesController, type: :controller do
  describe '#index' do
    it 'shows all degrees' do
      expect(get: admin_degrees_path).to route_to(controller: 'admin/degrees', action: 'index')
    end
  end
  describe '#new' do
    it 'creates a degree' do
      expect(get: new_admin_degree_path).to route_to(controller: 'admin/degrees', action: 'new')
    end
  end
  describe '#create' do
    it 'ceates a degree' do
      expect(post: '/admin/degrees', params: { degree: { name: 'new degree', description: 'degree description' } }).to route_to(controller: 'admin/degrees', action: 'create')
    end
  end
  describe '#edit' do
    let(:degree) { FactoryBot.create(:degree) }
    it 'edits an existing degree' do
      expect(get: edit_admin_degree_path(degree.id)).to route_to(controller: 'admin/degrees', action: 'edit', id: degree.id.to_s)
    end
  end
  describe '#edit' do
    it 'edits a degree' do
      degree = FactoryBot.create :degree
      expect(patch: "/admin/degrees/#{degree.id}", params: { degree: { id: degree.id, name: degree.name, description: 'a different description', degree_type_id: degree.degree_type_id } }).to route_to(controller: 'admin/degrees', action: 'update', id: degree.id.to_s)
    end
  end
end
