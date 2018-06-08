require 'presenters/presenters_spec_helper'
RSpec.describe Author::SubmissionsIndexView do
  let(:existing_author) { FactoryBot.create :author, opt_out_default: false }
  let(:view_for_existing_author) { described_class.new existing_author }
  let(:new_author) { Author.new }
  let(:view_for_new_author) { described_class.new new_author }
  let(:ldap_author) { FactoryBot.create :author, :author_from_ldap, opt_out_default: false }
  let(:view_for_ldap_author) { described_class.new ldap_author }

  describe '#update_contact_information?' do
    it 'returns true for a remote user that is not in our database' do
      expect(view_for_new_author).to be_update_contact_information
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
        it 'returns no_submissions' do
          FactoryBot.create :submission, :released_for_publication, author: existing_author
          expect(view_for_ldap_author.partial_name).to eq 'no_submissions'
        end
    end
  end
end
