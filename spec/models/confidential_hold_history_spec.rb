# frozen_string_literal: true

require 'model_spec_helper'

RSpec.describe ConfidentialHoldHistory, type: :model do
  it { is_expected.to have_db_column(:author_id).of_type(:integer).with_options(null: false) }
  it { is_expected.to have_db_column(:set_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:removed_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:set_by).of_type(:string) }
  it { is_expected.to have_db_column(:removed_by).of_type(:string) }
  it { is_expected.to belong_to(:author).class_name('Author') }
end
