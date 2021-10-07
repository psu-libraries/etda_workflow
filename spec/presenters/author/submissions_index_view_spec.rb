require 'presenters/presenters_spec_helper'
RSpec.describe Author::SubmissionsIndexView do
  let(:existing_author) { FactoryBot.create :author }
  let(:author_wo_address) { FactoryBot.create :author, alternate_email_address: 'abc123@email.com' }
  let(:view_for_existing_author) { described_class.new existing_author }
  let(:new_author) { Author.new }
  let(:view_for_new_author) { described_class.new new_author }
  let(:ldap_author) { FactoryBot.create :author, :author_from_ldap }
  let(:view_for_ldap_author) { described_class.new ldap_author }

  describe '#update_contact_information?' do
    it 'returns true for a remote user that is not in our database' do
      expect(view_for_new_author).to be_update_contact_information
    end
    it 'returns true for an author that does not have address_1 data' do
      author_wo_address.address_1 = nil
      expect(described_class.new(author_wo_address)).to be_update_contact_information
    end
    it 'returns false for a remote user that is in our database' do
      expect(view_for_existing_author).not_to be_update_contact_information
    end
  end

  describe '#partial_name' do
    context 'When the remote user is not in our database' do
      it 'returns confirm_contact_information_instructions' do
        expect(view_for_new_author.partial_name).to eq 'confirm_contact_information_instructions'
      end
    end

    context 'When the remote user exists in our database and has submissions' do
      it "returns the author's submissions" do
        FactoryBot.create :submission, author: existing_author
        expect(view_for_existing_author.partial_name).to eq 'submissions'
      end
    end

    context 'and does not have any submissions' do
      it 'returns an empty index' do
        expect(view_for_existing_author.partial_name).to eq 'no_submissions'
      end
    end

    context 'When author is in database, populated from LDAP entry and has no unpublished submissions' do
      it 'returns confirm_contact_information_instructions' do
        FactoryBot.create :submission, :released_for_publication, author: existing_author
        expect(view_for_ldap_author.partial_name).to eq 'confirm_contact_information_instructions'
      end
    end
  end
end
