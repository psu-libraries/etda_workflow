# frozen_string_literal: true
require 'rails_helper'
require 'shoulda-matchers'

RSpec.describe Program, type: :model do
  it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:name).of_type(:string) }
  it { is_expected.to have_db_column(:is_active).of_type(:boolean) }
  it { is_expected.to have_db_column(:legacy_id).of_type(:integer) }
  it { is_expected.to have_db_column(:legacy_old_id).of_type(:integer) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }

  it { is_expected.to have_db_index(:legacy_id) }
  it { is_expected.to validate_presence_of :name }

  it { is_expected.to validate_uniqueness_of :name }

  it { is_expected.to have_many :submissions }

  describe '#active_status' do
    context 'When is_active is false or nil' do
      it 'returns No' do
        described_class.new(is_active: false)
        expect(described_class.new(is_active: false).active_status).to eq('No')
        program = described_class.new
        program.is_active = nil
        expect(program.active_status).to eq('No')
      end
    end
    context 'When is_active is true' do
      it 'returns Yes' do
        expect(described_class.new(is_active: true).active_status).to eq('Yes')
      end
    end
  end
  describe '#set_is_active_to_true' do
    it "Sets activation status to true for new instances" do
      testprogram = described_class.create(name: 'testprogram')
      expect(testprogram.is_active).to be_truthy
    end
  end
end
