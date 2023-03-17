# frozen_string_literal: true

require 'rails_helper'
require 'shoulda-matchers'

RSpec.describe ConfidentialHoldUpdateService do
  let!(:author) { FactoryBot.create :author, confidential_hold: false, confidential_hold_set_at: nil }

  describe '#update' do
    it 'sets confidential hold and history' do
      allow_any_instance_of(LdapUniversityDirectory).to receive(:retrieve).and_return(confidential_hold: true)
      described_class.update(author)
      expect(Author.find(author.id).confidential_hold).to eq true
      expect(Author.find(author.id).confidential_hold_set_at).to be_present
      expect(Author.find(author.id).confidential_hold_histories.count).to eq 1
      expect(Author.find(author.id).confidential_hold_histories.first.set_by).to eq 'login_controller'
      expect(Author.find(author.id).confidential_hold_histories.first.set_at).to be_present
      expect(Author.find(author.id).confidential_hold_histories.first.removed_by).not_to be_present
      expect(Author.find(author.id).confidential_hold_histories.first.removed_at).not_to be_present
    end

    it 'removes confidential hold and sets history' do
      author.update confidential_hold: true, confidential_hold_set_at: DateTime.now
      FactoryBot.create(:confidential_hold_history, author:)
      allow_any_instance_of(LdapUniversityDirectory).to receive(:retrieve).and_return(confidential_hold: false)
      described_class.update(author)
      expect(Author.find(author.id).confidential_hold).to eq false
      expect(Author.find(author.id).confidential_hold_set_at).not_to be_present
      expect(Author.find(author.id).confidential_hold_histories.count).to eq 1
      expect(Author.find(author.id).confidential_hold_histories.first.set_by).to eq 'login_controller'
      expect(Author.find(author.id).confidential_hold_histories.first.set_at).to be_present
      expect(Author.find(author.id).confidential_hold_histories.first.removed_by).to eq 'login_controller'
      expect(Author.find(author.id).confidential_hold_histories.first.removed_at).to be_present
    end

    it 'adds another history' do
      FactoryBot.create(:confidential_hold_history, author:, removed_at: DateTime.now, removed_by: 'login_controller'
      allow_any_instance_of(LdapUniversityDirectory).to receive(:retrieve).and_return(confidential_hold: true)
      described_class.update(author)
      expect(Author.find(author.id).confidential_hold).to eq true
      expect(Author.find(author.id).confidential_hold_set_at).to be_present
      expect(Author.find(author.id).confidential_hold_histories.count).to eq 2
    end

    it 'updates last history record' do
      author.update confidential_hold: true, confidential_hold_set_at: DateTime.now
      FactoryBot.create(:confidential_hold_history, author:, removed_at: DateTime.now, removed_by: 'login_controller'
      FactoryBot.create(:confidential_hold_history, author:)
      allow_any_instance_of(LdapUniversityDirectory).to receive(:retrieve).and_return(confidential_hold: false)
      described_class.update(author)
      expect(Author.find(author.id).confidential_hold_histories.count).to eq 2
      expect(Author.find(author.id).confidential_hold_histories.last.removed_at).to be_present
      expect(Author.find(author.id).confidential_hold_histories.last.removed_by).to eq 'login_controller'
    end
  end

  describe '#update_all' do
    let!(:author2) { FactoryBot.create :author, confidential_hold: false, confidential_hold_set_at: nil }

    it 'updates confidential hold history with daily report metadata' do
      allow(described_class).to receive(:ldap_result_connected).and_return({ confidential_hold: true })
      described_class.update_all
      expect(Author.find(author.id).confidential_hold_histories.first.set_by).to eq 'rake_task'
      expect(Author.find(author.id).confidential_hold).to eq true
      expect(Author.find(author2.id).confidential_hold_histories.first.set_by).to eq 'rake_task'
      expect(Author.find(author2.id).confidential_hold).to eq true
    end
  end
end
