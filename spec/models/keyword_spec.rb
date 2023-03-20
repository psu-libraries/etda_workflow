# frozen_string_literal: true

require 'model_spec_helper'

RSpec.describe Keyword, type: :model do
  it { is_expected.to have_db_column(:id).of_type(:integer).with_options(null: false) }

  it { is_expected.to have_db_column(:word).of_type(:text) }
  it { is_expected.to have_db_column(:submission_id).of_type(:integer) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:legacy_id).of_type(:integer) }

  it { is_expected.to have_db_index(:submission_id) }
  it { is_expected.to have_db_index(:legacy_id) }

  it { is_expected.to belong_to(:submission).class_name('Submission') }

  it { is_expected.to validate_presence_of(:submission_id) }
  it { is_expected.to validate_presence_of(:word) }

  it 'displays a hint' do
    expect(described_class.hint).to eql("Enter keywords in the following box.  Multiple keywords can be entered and one keyword entry may contain multiple words.  Use a comma to separate keyword entries. To delete a keyword, click the 'X' or use the backspace key.")
  end
end
