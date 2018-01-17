# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  describe 'routing' do
    context 'author' do
      it 'sends /logout to sessions#destroy' do
        expect(get: '/logout').to route_to(controller: 'application', action: 'logout')
        expect(destroy_author_session_path).to eq('/author/sign_out')
      end
      it 'sends /login to sessions#new' do
        expect(get: '/login').to route_to(controller: 'application', action: 'login')
        expect(new_author_session_path).to eq('/author/sign_in')
      end
    end
    context 'admin' do
      it 'sends /logout to sessions#destroy' do
        expect(get: '/logout').to route_to(controller: 'application', action: 'logout')
        expect(destroy_admin_session_path).to eq('/admin/sign_out')
      end
      it 'sends /login to sessions#new' do
        expect(get: '/login').to route_to(controller: 'application', action: 'login')
        expect(new_admin_session_path).to eq('/admin/sign_in')
      end
    end
  end
  describe 'part2' do
    describe '#destroy' do
      it 'redirects to the central logout page and destroy the cookie' do
        expect(get: '/logout').to route_to(controller: 'application', action: 'logout')
      end
    end
    describe '#new' do
      it 'redirects to the central login page' do
        expect(get: '/login').to route_to(controller: 'application', action: 'login')
      end
    end
  end
end
