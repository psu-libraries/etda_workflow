# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::AuthorsController, type: :controller do
  describe '#index' do
    it 'shows all authors' do
      expect(get: admin_authors_path).to route_to(controller: 'admin/authors', action: 'index')
    end
  end

  describe '#edit' do
    let(:author) { FactoryBot.create(:author) }

    it 'edits an existing author' do
      expect(get: edit_admin_author_path(author.id)).to route_to(controller: 'admin/authors', action: 'edit', id: author.id.to_s)
    end
  end

  describe '#edit' do
    it 'edits an author' do
      author = FactoryBot.create :author
      expect(patch: "/admin/authors/#{author.id}", params: { author: { id: author.id, first_name: author.first_name, last_name: 'Addifferentlastname', psu_email_address: author.psu_email_address, alternate_email_address: author.alternate_email_address, phone_number: author.phone_number } }).to route_to(controller: 'admin/authors', action: 'update', id: author.id.to_s)
    end
  end

  describe '#email_contact_list' do
    it 'lists authors with released publications' do
      expect(get: '/admin/authors/contact_list').to route_to(controller: 'admin/authors', action: 'email_contact_list')
    end
  end
end
