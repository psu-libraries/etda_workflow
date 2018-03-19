# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ActionDispatch::Routing do
  context 'admin routes' do
    it 'degrees routes' do
      expect(get: 'admin/degrees').to route_to(controller: 'admin/degrees', action: 'index')
      expect(get: 'admin/degrees/new').to route_to(controller: 'admin/degrees', action: 'new')
      expect(get: 'admin/degrees/1/edit').to route_to(controller: 'admin/degrees', action: 'edit', id: '1')
      expect(patch: 'admin/degrees/1').to route_to(controller: 'admin/degrees', action: 'update', id: '1')
    end

    it 'programs routes' do
      expect(get: 'admin/programs').to route_to(controller: 'admin/programs', action: 'index')
      expect(get: 'admin/programs/new').to route_to(controller: 'admin/programs', action: 'new')
      expect(get: 'admin/programs/1/edit').to route_to(controller: 'admin/programs', action: 'edit', id: '1')
      expect(patch: 'admin/programs/1').to route_to(controller: 'admin/programs', action: 'update', id: '1')
    end

    # it 'authors routes' do
    #   expect(get: 'admin/authors').to route_to(controller: 'admin/authors', action: 'index')
    #   expect(get: 'admin/admin/new').to route_to(controller: 'admin/authors', action: 'new')
    #   expect(get: 'admin/admin/1/edit').to route_to(controller: 'admin/authors', action: 'edit', id: '1')
    #   expect(patch: 'admin/admin/1').to route_to(controller: 'admin/authors', action: 'update', id: '1')
    # end

    # it 'routes submissions' do
    #   expect(get: 'admin/submissions').to route_to(controller: 'admin/submissions', action: 'index')
    #   expect(get: 'admin/submissions/new').to route_to(controller: 'admin/submissions', action: 'new')
    #   expect(get: 'admin/submissions/1/edit').to route_to(controller: 'admin/submissions', action: 'edit', id: '1')
    #   expect(patch: 'admin/submissions/1').to route_to(controller: 'admin/submissions', action: 'update', id: '1')
    #
    # end

    it 'routes error messages' do
      expect(get: '/404').to route_to(controller: 'errors', action: 'render_404')
      expect(get: '/500').to route_to(controller: 'errors', action: 'render_500')
      expect(get: '/401').to route_to(controller: 'errors', action: 'render_401')
    end

    it 'routes email_contact_form' do
      expect(get: '/email_contact_form').to route_to(controller: 'email_contact_form', action: 'new')
      expect(post: '/email_contact_form').to route_to(controller: 'email_contact_form', action: 'create')
    end
  end
end
