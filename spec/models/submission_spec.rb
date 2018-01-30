# frozen_string_literal: true

require 'model_spec_helper'

RSpec.describe Submission, type: :model do
  submission = described_class.new(access_level: AccessLevel.OPEN_ACCESS.current_access_level)

  it { is_expected.to have_db_column(:author_id).of_type(:integer) }
  it { is_expected.to have_db_column(:program_id).of_type(:integer) }
  it { is_expected.to have_db_column(:degree_id).of_type(:integer) }
  it { is_expected.to have_db_column(:semester).of_type(:string) }
  it { is_expected.to have_db_column(:year).of_type(:integer) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:status).of_type(:string) }
  it { is_expected.to have_db_column(:title).of_type(:string) }
  it { is_expected.to have_db_column(:format_review_notes).of_type(:text) }
  it { is_expected.to have_db_column(:final_submission_notes).of_type(:text) }
  it { is_expected.to have_db_column(:defended_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:abstract).of_type(:text) }
  it { is_expected.to have_db_column(:access_level).of_type(:string) }
  it { is_expected.to have_db_column(:has_agreed_to_terms).of_type(:boolean) }
  it { is_expected.to have_db_column(:committee_provided_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:format_review_files_first_uploaded_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:format_review_files_uploaded_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:format_review_rejected_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:format_review_approved_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:final_submission_files_first_uploaded_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:final_submission_files_uploaded_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:final_submission_rejected_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:final_submission_approved_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:released_metadata_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:legacy_id).of_type(:integer) }
  it { is_expected.to have_db_column(:final_submission_legacy_id).of_type(:integer) }
  it { is_expected.to have_db_column(:final_submission_legacy_old_id).of_type(:integer) }
  it { is_expected.to have_db_column(:format_review_legacy_id).of_type(:integer) }
  it { is_expected.to have_db_column(:format_review_legacy_old_id).of_type(:integer) }
  it { is_expected.to have_db_column(:admin_notes).of_type(:string) }
  it { is_expected.to have_db_column(:is_printed).of_type(:boolean) }
  it { is_expected.to have_db_column(:allow_all_caps_in_title).of_type(:boolean) }
  it { is_expected.to have_db_column(:public_id).of_type(:string) }
  it { is_expected.to have_db_column(:lion_path_degree_code).of_type(:string) }
  it { is_expected.to have_db_column(:restricted_notes).of_type(:text) }

  it { is_expected.to belong_to(:author).class_name('Author') }
  it { is_expected.to belong_to(:degree).class_name('Degree') }
  it { is_expected.to belong_to(:program).class_name('Program') }

  it { is_expected.to have_db_index(:author_id) }
  it { is_expected.to have_db_index(:degree_id) }
  it { is_expected.to have_db_index(:program_id) }
  it { is_expected.to have_db_index(:legacy_id) }
  it { is_expected.to have_db_index(:final_submission_legacy_id) }
  it { is_expected.to have_db_index(:final_submission_legacy_old_id) }
  it { is_expected.to have_db_index(:format_review_legacy_id) }
  it { is_expected.to have_db_index(:format_review_legacy_old_id) }
  it { is_expected.to have_db_index(:public_id).unique(true) }

  it { is_expected.to validate_presence_of :author_id }
  it { is_expected.to validate_presence_of :title }
  it { is_expected.to validate_presence_of :program_id }
  it { is_expected.to validate_presence_of :degree_id }
  it { is_expected.to validate_presence_of :semester }
  it { is_expected.to validate_presence_of :year }
  # it { is_expected.to validate_uniqueness_of :public_id }
  it { is_expected.not_to validate_presence_of :restricted_notes }

  it { is_expected.to belong_to :author }
  it { is_expected.to belong_to :degree }
  it { is_expected.to belong_to :program }

  it { is_expected.to have_many :committee_members }
  it { is_expected.to have_many :format_review_files }
  it { is_expected.to have_many :final_submission_files }
  it { is_expected.to have_many :keywords }
  it { is_expected.to have_many :invention_disclosures }

  it { is_expected.to validate_inclusion_of(:semester).in_array(Semester::SEMESTERS) }
  # it { is_expected.to validate_inclusion_of(:access_level).in_array(AccessLevel::ACCESS_LEVEL_KEYS) }

  it { is_expected.to validate_numericality_of :year }

  it { is_expected.to validate_inclusion_of(:status).in_array(SubmissionStatus::WORKFLOW_STATUS) }

  it { is_expected.to validate_length_of(:title).is_at_most(400) }

  it { is_expected.to accept_nested_attributes_for :committee_members }
  it { is_expected.to accept_nested_attributes_for :format_review_files }
  it { is_expected.to accept_nested_attributes_for :final_submission_files }
  # it { is_expected.to accept_nested_attributes_for :invention_disclosures }

  it { is_expected.to delegate_method(:program_name).to(:program).as(:name) }
  it { is_expected.to delegate_method(:degree_name).to(:degree).as(:name) }
  it { is_expected.to delegate_method(:degree_type).to(:degree) }
  it { is_expected.to delegate_method(:required_committee_roles).to(:degree_type) }
  it { is_expected.to delegate_method(:author_first_name).to(:author).as(:first_name) }
  it { is_expected.to delegate_method(:author_last_name).to(:author).as(:last_name) }
  it { is_expected.to delegate_method(:author_full_name).to(:author).as(:full_name) }
  it { is_expected.to delegate_method(:author_psu_email_address).to(:author).as(:psu_email_address) }

  it 'has an access_level_key' do
    submission = FactoryBot.create :submission, access_level: 'open_access'
    expect(submission.access_level_key).to eq('open_access')
  end

  context 'invention disclosure' do
    it 'rejects an empty disclosure number' do
      expect(submission.reject_disclosure_number(id: nil, submission_id: nil, id_number: nil, created_at: nil, updated_at: nil)).to be_truthy
    end
  end
  context 'using lionpath?' do
    it 'knows when lion_path integration is being used' do
      author = Author.new
      author.inbound_lion_path_record = nil
      submission = Submission.new(author: author)
      expect(submission).not_to be_using_lionpath
    end
  end
  context 'academic plan' do
    it 'knows the correct academic plan' do
      author = FactoryBot.create(:author)
      inbound_record = FactoryBot.create(:inbound_lion_path_record, author: author)
      author.inbound_lion_path_record = inbound_record
      submission = FactoryBot.create(:submission, author: author)
      expect(submission.academic_plan).not_to be_nil
    end
  end
end
