# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContactFormController, type: :controller do
  describe '#new' do
    it 'opens the contact for for an authenticated user' do
      expect(get: contact_form_new_path).to route_to(controller: 'contact_form', action: 'new')
    end
  end

  describe '#create' do
    it 'sends the contact form' do
      expect(post: contact_form_index_path).to route_to(controller: 'contact_form', action: 'create')
    end
  end
end
