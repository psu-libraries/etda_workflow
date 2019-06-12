require 'rails_helper'

RSpec.describe CommitteeMemberToken, type: :model do
  subject { described_class.new }

  it { is_expected.to have_db_column(:committee_member_id).of_type(:integer) }
  it { is_expected.to have_db_column(:authentication_token).of_type(:string) }
  it { is_expected.to have_db_index(:committee_member_id) }
  it { is_expected.to belong_to(:committee_member).class_name('CommitteeMember') }
end