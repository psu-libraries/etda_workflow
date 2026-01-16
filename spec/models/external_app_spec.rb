# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExternalApp do
  describe 'table' do
    it { is_expected.to have_db_column(:name).of_type(:string) }

    it { is_expected.to have_db_index(:name) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:api_tokens) }
  end

  describe 'validations' do
    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
    it { is_expected.to validate_presence_of(:name) }
  end
end
