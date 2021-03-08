require 'model_spec_helper'

RSpec.describe ProgramChair, type: :model do
  it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:program_id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:access_id).of_type(:string).with_options(null: false) }
  it { is_expected.to have_db_column(:first_name).of_type(:string) }
  it { is_expected.to have_db_column(:last_name).of_type(:string) }
  it { is_expected.to have_db_column(:campus).of_type(:string) }
  it { is_expected.to have_db_column(:phone).of_type(:integer) }
  it { is_expected.to have_db_column(:email).of_type(:string) }
  it { is_expected.to have_db_column(:lionpath_updated_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }

  it { is_expected.to belong_to :program }
end
