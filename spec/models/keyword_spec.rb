# frozen_string_literal: true
require 'rails_helper'
require 'shoulda-matchers'

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
end
