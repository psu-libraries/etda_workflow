require 'rails_helper'

RSpec.describe Approver, type: :model do
  subject { described_class.new }

  it { is_expected.to have_db_column(:access_id).of_type(:string) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:remember_created_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:sign_in_count).of_type(:integer) }
  it { is_expected.to have_db_column(:current_sign_in_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:last_sign_in_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:current_sign_in_ip).of_type(:string) }
  it { is_expected.to have_db_column(:last_sign_in_ip).of_type(:string) }
  it { is_expected.to have_many :committee_members }

  it { is_expected.to validate_uniqueness_of(:access_id) }
  it { is_expected.to validate_presence_of(:access_id) }

  describe '#status_merge' do
    let(:submission) { FactoryBot.create :submission }
    let(:cm1) { FactoryBot.create :committee_member, access_id: 'abc123', status: 'approved' }
    let(:cm2) { FactoryBot.create :committee_member, access_id: 'abc123' }

    it 'merges the statuses of committee members with the same access id' do
      submission.committee_members << [cm1, cm2]
      described_class.status_merge(cm1)
      expect(cm2.status).to eq 'approved'
    end
  end
end
