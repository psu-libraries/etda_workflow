# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ErrorsController, type: :controller do
  describe 'renders error messages' do
    it 'renders 500 errors' do
      expect(get: '/500').to route_to(controller: 'errors', action: 'render_500')
      get 'render_500'
      expect(response).to render_template('error/500')
    end

    it 'renders 404 errors' do
      expect(get: '/404', format: :html).to route_to(controller: 'errors', action: 'render_404')
      get 'render_404'
      expect(response).to render_template('error/404')
    end

    it 'renders 401 errors' do
      expect(get: '/401').to route_to(controller: 'errors', action: 'render_401')
      get 'render_401'
      expect(response).to render_template('error/401')
    end
  end
end
