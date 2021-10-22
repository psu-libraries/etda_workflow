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

    context 'approver' do
      it 'sends /logout to sessions#destroy' do
        expect(get: '/logout').to route_to(controller: 'application', action: 'logout')
        expect(destroy_approver_session_path).to eq('/approver/sign_out')
      end
      it 'sends /login to sessions#new' do
        expect(get: '/login').to route_to(controller: 'application', action: 'login')
        expect(new_approver_session_path).to eq('/approver/sign_in')
      end
    end
  end

  describe 'special committee page' do
    it 'displays the committee page' do
      expect(get: '/special_committee/1').to route_to(controller: 'special_committee', action: 'main', authentication_token: '1')
    end
  end

  describe 'login methods' do
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

  describe '#about' do
    it 'displays the about page' do
      expect(get: '/about').to route_to(controller: 'application', action: 'about')
    end
  end

  describe '#autocomplete' do
    it 'returns an array of employee names to use in committee member form' do
      expect(get: '/committee_members/autocomplete?term=Smith').to route_to(controller: 'application', action: 'autocomplete', term: 'Smith')
    end
  end

  describe '#render_404' do
    it 'displays a 404 error' do
      expect(get: '/404').to route_to(controller: 'errors', action: 'render_404')
    end
  end

  describe '#render_500' do
    it 'displays a 500 error' do
      expect(get: '/500').to route_to(controller: 'errors', action: 'render_500')
    end
  end

  describe '#render_401' do
    it 'displays a 401 error' do
      expect(get: '/401').to route_to(controller: 'errors', action: 'render_401')
    end
  end

  # describe 'rescue errors' do
  #   it 'responds to errors' do
  #     allow(Rails.env).to receive(:production?).and_return(true)
  #     expect{ raise ActionController::RoutingError }.to raise_error
  #   end
  # end
end
