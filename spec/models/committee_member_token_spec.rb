require 'rails_helper'

RSpec.describe CommitteeMemberToken, type: :model do
  subject { described_class.new }

  it { is_expected.to have_db_column(:committee_member_id).of_type(:integer) }
  it { is_expected.to have_db_column(:authentication_token).of_type(:string) }
  it { is_expected.to have_db_column(:token_created_on).of_type(:date) }
  it { is_expected.to have_db_index(:committee_member_id) }
  it { is_expected.to belong_to(:committee_member).class_name('CommitteeMember') }

  context 'when authentication_token changes' do
    let(:committee_member_token) { FactoryBot.create :committee_member_token, token_created_on: Date.yesterday }
    it 'updates token_created_on' do
      expect(committee_member_token.token_created_on).to eq Date.yesterday
      committee_member_token.update_attribute :authentication_token, '123fds654'
      expect(CommitteeMemberToken.find(committee_member_token.id).token_created_on).to eq Date.today
    end

    it "if nil, doesn't update token_created_on" do
      expect(committee_member_token.token_created_on).to eq Date.yesterday
      committee_member_token.update_attribute :authentication_token, nil
      expect(CommitteeMemberToken.find(committee_member_token.id).token_created_on).to eq Date.yesterday
    end
  end
end
