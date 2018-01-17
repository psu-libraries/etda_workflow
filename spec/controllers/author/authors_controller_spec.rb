# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Author::AuthorsController, type: :controller do
  describe '#edit' do
    let(:author) { FactoryBot.create(:author) }

    it 'edits an existing degree' do
      expect(get: edit_author_author_path(author.id)).to route_to(controller: 'author/authors', action: 'edit', id: author.id.to_s)
    end
  end
  describe '#update' do
    it 'edits an author' do
      author = FactoryBot.create :author
      expect(patch: "/author/authors/#{author.id}", params: { author: { id: author.id, first_name: author.first_name, last_name: author.last_name, psu_email_address: author.psu_email_address, alternate_email_address: author.alternate_email_address } }).to route_to(controller: 'author/authors', action: 'update', id: author.id.to_s)
    end
  end
  describe '#technical_tips' do
    it 'displays technical tips page' do
      expect(get: 'author/tips').to route_to(controller: 'author/authors', action: 'technical_tips')
    end
  end
end
