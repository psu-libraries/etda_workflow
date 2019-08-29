# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Author::EmailContactFormController, type: :controller do
  describe '#new' do
    it 'opens the email contact form for an authenticated user' do
      expect(get: email_contact_form_new_path).to route_to(controller: 'email_contact_form', action: 'new')
    end
  end

  describe '#create' do
    it 'sends the contact form' do
      expect(post: email_contact_form_index_path).to route_to(controller: 'email_contact_form', action: 'create')
    end
  end
end
