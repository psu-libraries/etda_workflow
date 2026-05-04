# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApiToken do
  describe 'table' do
    it { is_expected.to have_db_column(:token).of_type(:string) }
    it { is_expected.to have_db_column(:last_used_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }
    it { is_expected.to have_db_column(:external_app_id).of_type(:integer) }

    it { is_expected.to have_db_index(:external_app_id) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:external_app) }
  end

  describe 'creating a new token' do
    let(:new_token) { build(:api_token, token: nil) }

    it 'sets a value for the token' do
      new_token.save!
      expect(new_token.token.length).to eq 96
    end
  end

  describe '#record_usage' do
    let(:token) { create(:api_token) }

    it 'touches last_used_at in the database' do
      expect do
        token.record_usage
      end.to(change do
        token.reload.last_used_at
      end)
    end
  end
end
