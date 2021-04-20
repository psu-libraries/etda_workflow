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
  it { is_expected.to have_db_column(:role).of_type(:string) }

  it { is_expected.to belong_to :program }

  describe "validations" do
    let(:program_chair) { FactoryBot.create :program_chair }

    context "when role is not in #roles" do
      it "is not valid" do
        program_chair.update role: 'Not correct'
        expect(program_chair.valid?).to eq false
        program_chair.update role: "HDJSIWKSMS"
        expect(program_chair.valid?).to eq false
      end
    end

    context "when role is in #roles" do
      it "is valid" do
        expect(program_chair.valid?).to eq true
        program_chair.update role: 'Professor in Charge'
        expect(program_chair.valid?).to eq true
      end
    end
  end
end
