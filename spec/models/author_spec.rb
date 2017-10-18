# frozen_string_literal: true
require 'rails_helper'
require 'shoulda-matchers'

RSpec.describe Author, type: :model do
  subject { described_class.new }

  it { is_expected.to have_db_column(:access_id).of_type(:string) }
  it { is_expected.to have_db_column(:first_name).of_type(:string) }
  it { is_expected.to have_db_column(:last_name).of_type(:string) }
  it { is_expected.to have_db_column(:middle_name).of_type(:string) }
  it { is_expected.to have_db_column(:alternate_email_address).of_type(:string) }
  it { is_expected.to have_db_column(:psu_email_address).of_type(:string) }
  it { is_expected.to have_db_column(:phone_number).of_type(:string) }
  it { is_expected.to have_db_column(:address_1).of_type(:string) }
  it { is_expected.to have_db_column(:address_2).of_type(:string) }
  it { is_expected.to have_db_column(:city).of_type(:string) }
  it { is_expected.to have_db_column(:state).of_type(:string) }
  it { is_expected.to have_db_column(:zip).of_type(:string) }
  it { is_expected.to have_db_column(:is_alternate_email_public).of_type(:boolean) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:legacy_id).of_type(:integer) }
  it { is_expected.to have_db_column(:confidential_hold).of_type(:boolean) }
  it { is_expected.to have_db_column(:is_admin).of_type(:boolean) }
  it { is_expected.to have_db_column(:is_site_admin).of_type(:boolean) }

  it { is_expected.to have_db_column(:remember_created_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:sign_in_count).of_type(:integer) }
  it { is_expected.to have_db_column(:remember_created_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:current_sign_in_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:last_sign_in_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:current_sign_in_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:current_sign_in_ip).of_type(:string) }
  it { is_expected.to have_db_column(:last_sign_in_ip).of_type(:string) }
  it { is_expected.to have_db_column(:country).of_type(:string) }
  it { is_expected.to have_db_column(:psu_idn).of_type(:string) }

  it { is_expected.to have_db_index(:legacy_id) }
end
