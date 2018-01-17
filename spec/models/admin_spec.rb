# frozen_string_literal: true

require 'model_spec_helper'

RSpec.describe Admin, type: :model do
  subject { described_class.new }

  it { is_expected.to have_db_column(:access_id).of_type(:string) }
  it { is_expected.to have_db_column(:first_name).of_type(:string) }
  it { is_expected.to have_db_column(:last_name).of_type(:string) }
  it { is_expected.to have_db_column(:psu_email_address).of_type(:string) }
  it { is_expected.to have_db_column(:phone_number).of_type(:string) }
  it { is_expected.to have_db_column(:address_1).of_type(:string) }
  it { is_expected.to have_db_column(:psu_idn).of_type(:string) }
  it { is_expected.to have_db_column(:administrator).of_type(:boolean) }
  it { is_expected.to have_db_column(:site_administrator).of_type(:boolean) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:remember_created_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:sign_in_count).of_type(:integer) }
  it { is_expected.to have_db_column(:current_sign_in_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:last_sign_in_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:current_sign_in_ip).of_type(:string) }

  context '#admin_user?' do
    it 'knows when an author has admin privileges' do
      expect(described_class.new(access_id: 'me123', administrator: true)).to be_administrator
      expect(described_class.new(access_id: 'me123', administrator: nil)).not_to be_administrator
    end
  end
  context '#active_admin_user?' do
    it 'knows when an author has site administration privileges' do
      author = described_class.new(access_id: 'me123')
      author.site_administrator = true
      expect(author).to be_site_administrator
      author.site_administrator = false
      expect(author).not_to be_site_administrator
    end
  end
end
