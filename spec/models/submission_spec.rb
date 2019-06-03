# frozen_string_literal: true

require 'model_spec_helper'

RSpec.describe Submission, type: :model do
  submission = described_class.new(access_level: AccessLevel.OPEN_ACCESS.current_access_level, status: 'collecting final submission files')
  submission.author_edit = true

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
  it { is_expected.to have_db_column(:has_agreed_to_publication_release).of_type(:boolean) }
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
  it { is_expected.to have_db_column(:publication_release_terms_agreed_to_at).of_type(:datetime) }

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

  it { is_expected.to validate_presence_of :author_id  }
  it { is_expected.to validate_presence_of :program_id }
  it { is_expected.to validate_presence_of :degree_id }
  it { is_expected.not_to validate_presence_of :restricted_notes }

  it { is_expected.to belong_to :author }
  it { is_expected.to belong_to :degree }
  it { is_expected.to belong_to :program }

  it { is_expected.to have_many :committee_members }
  it { is_expected.to have_many :format_review_files }
  it { is_expected.to have_many :final_submission_files }
  it { is_expected.to have_many :keywords }
  it { is_expected.to have_many :invention_disclosures }

  it { is_expected.to validate_inclusion_of(:access_level).in_array(AccessLevel::ACCESS_LEVEL_KEYS) }

  it { is_expected.to validate_inclusion_of(:status).in_array(SubmissionStatus::WORKFLOW_STATUS) }

  it { is_expected.to accept_nested_attributes_for :committee_members }
  it { is_expected.to accept_nested_attributes_for :format_review_files }
  it { is_expected.to accept_nested_attributes_for :final_submission_files }

  it { is_expected.to delegate_method(:program_name).to(:program).as(:name) }
  it { is_expected.to delegate_method(:degree_name).to(:degree).as(:name) }
  it { is_expected.to delegate_method(:degree_type).to(:degree) }
  it { is_expected.to delegate_method(:required_committee_roles).to(:degree_type) }
  it { is_expected.to delegate_method(:author_first_name).to(:author).as(:first_name) }
  it { is_expected.to delegate_method(:author_last_name).to(:author).as(:last_name) }
  it { is_expected.to delegate_method(:author_full_name).to(:author).as(:full_name) }
  it { is_expected.to delegate_method(:author_psu_email_address).to(:author).as(:psu_email_address) }

  describe 'conditional submission validations' do
    submission = described_class.new(access_level: AccessLevel.OPEN_ACCESS.current_access_level)
    submission.author_edit = false

    it 'has an access_level_key' do
      submission = FactoryBot.create :submission, access_level: 'open_access'
      expect(submission.access_level_key).to eq('open_access')
    end

    it 'validates semester only when authors are editing' do
      submission = FactoryBot.create :submission
      submission.semester = 'Fall'
      expect(submission).to be_valid
      submission.semester = ''
      submission.author_edit = true
      expect(submission).not_to be_valid
      submission.semester = 'bogus'
      expect(submission).not_to be_valid
      submission.author_edit = false
      expect(submission).to be_valid
      submission.semester = ''
      expect(submission).to be_valid
    end

    it 'validates year only when authors are editing' do
      submission = FactoryBot.create :submission
      submission.year = '2018'
      expect(submission).to be_valid
      submission.year = ''
      submission.author_edit = true
      expect(submission).not_to be_valid
      submission.year = 'abc'
      expect(submission).not_to be_valid
      submission.author_edit = false
      expect(submission).to be_valid
      submission.year = ''
      expect(submission).to be_valid
    end

    it 'validates title length when only authors are editing' do
      submission = FactoryBot.create :submission
      expect(submission).to be_valid
      long_title = ''
      11.times do
        long_title += '01234567890123456789012345678901234567890'
      end
      expect(long_title.length > 400).to be_truthy
      submission = FactoryBot.create :submission
      submission.allow_all_caps_in_title = true
      expect(submission).to be_valid
      submission.title = long_title
      submission.author_edit = true
      expect(submission).not_to be_valid
      submission.author_edit = false
      expect(submission).to be_valid
      submission.title = long_title.truncate(400)
      submission.author_edit = true
      expect(submission).to be_valid
    end

    it 'does not allow a blank title to be entered when authors are editing' do
      submission = FactoryBot.create :submission
      expect(submission).to be_valid
      submission.title = ''
      submission.author_edit = true
      expect(submission).not_to be_valid
      submission.author_edit = false
      expect(submission).to be_valid
    end

    context 'invention disclosure' do
      it 'rejects an empty disclosure number' do
        expect(submission.reject_disclosure_number(id: nil, submission_id: nil, id_number: nil, created_at: nil, updated_at: nil)).to be_falsey
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

    context 'keywords' do
      it 'has a list of keywords' do
        submission = Submission.new
        submission.keywords << Keyword.new(word: 'zero')
        submission.keywords << Keyword.new(word: 'one')
        submission.keywords << Keyword.new(word: 'two')
        expect(submission.delimited_keywords).to eq('zero,one,two')
        expect(submission.keyword_list).to eq(['zero', 'one', 'two'])
      end
    end

    context '#defended_at_date' do
      it 'returns defended_at date from student input' do
        submission = FactoryBot.create :submission, :released_for_publication
        expect(submission.defended_at).not_to be_blank if current_partner.graduate?
      end
    end

    context '#check_title_capitalization' do
      it 'identifies all caps in the title' do
        submission = Submission.new(title: 'THIS TITLE IS NOT ALLOWED')
        expect(submission.check_title_capitalization).to eq(["Please check that the title is properly capitalized. If you need to use upper-case words such as acronyms, you must select the option to allow it."])
        expect(submission.errors[:title]).to eq(["Please check that the title is properly capitalized. If you need to use upper-case words such as acronyms, you must select the option to allow it."])
      end
      it 'allows titles with < 4 uppercase, numbers, and symbols' do
        submission = Submission.new(title: 'THIS 1855 is %^&**% AlloweD')
        expect(submission.check_title_capitalization).to eq(nil)
        expect(submission.errors[:title]).to eq([])
      end
    end

    context '#restricted_to_institution?' do
      it 'returns true' do
        submission = Submission.new(access_level: 'restricted_to_institution')
        expect(submission).to be_restricted_to_institution
        submission.access_level = 'restricted'
        expect(submission).not_to be_restricted_to_institution
      end
    end

    context '#voting_committee_members' do
      it 'returns a list of voting committee members' do
        degree = Degree.new(degree_type: DegreeType.default, name: 'mydegree')
        submission = Submission.new(degree: degree)
        submission.build_committee_members_for_partners
        submission.committee_members.each_with_index do |cm, index|
          next if index == 0

          cm.is_voting = true
        end
        expect(submission.voting_committee_members).to eq(submission.voting_committee_members.collect { |cm| cm if cm.is_voting }.compact)
      end
    end

    context '#build_committee_members_for_partners' do
      it 'returns a list of required committee members' do
        degree = Degree.new(degree_type: DegreeType.default, name: 'mydegree')
        submission = Submission.new(degree: degree)
        expect(submission.build_committee_members_for_partners).not_to be_blank
      end
    end

    context '#publication_release_date' do
      it 'returns the release date for open access submissions' do
        submission = FactoryBot.create :submission, :released_for_publication
        date_to_release = Time.zone.yesterday
        expect(submission.publication_release_date(date_to_release)).to eq(date_to_release)
      end
      it 'returns release date plus 2 years for submissions not yet published and are not open access' do
        submission = FactoryBot.create :submission, :waiting_for_publication_release
        submission.access_level = 'restricted'
        date_to_release = Time.zone.tomorrow
        expect(submission.publication_release_date(date_to_release)).to eq(date_to_release + 2.years)
      end
    end

    context 'update timestamps' do
      it 'updates format review timestamps' do
        submission = FactoryBot.create :submission, :collecting_format_review_files
        expect(submission.format_review_files_uploaded_at).to be_nil
        expect(submission.format_review_files_first_uploaded_at).to be_nil
        time_now = Time.now
        # time_now_formatted = time_now.strftime("%Y-%m-%d %H:%M:%S.000000000 -0500")
        time_now_formatted = formatted_time(time_now)
        submission.update_format_review_timestamps!(time_now)
        expect(formatted_time(submission.format_review_files_uploaded_at)).to eq(time_now_formatted)
        expect(formatted_time(submission.format_review_files_first_uploaded_at)).to eq(time_now_formatted)
      end
      it 'updates final submission timestamps' do
        submission = FactoryBot.create :submission, :collecting_final_submission_files
        expect(submission.final_submission_files_uploaded_at).to be_nil
        expect(submission.final_submission_files_first_uploaded_at).to be_nil
        time_now = Time.now
        time_now_formatted = formatted_time(time_now)
        # time_now_formatted = time_now.strftime("%Y-%m-%d %H:%M:%S.000000000 -0500")
        submission.update_final_submission_timestamps!(time_now)
        expect(formatted_time(submission.final_submission_files_uploaded_at)).to eq(time_now_formatted)
        expect(formatted_time(submission.final_submission_files_first_uploaded_at)).to eq(time_now_formatted)
      end
    end
  end
end
