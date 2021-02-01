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
  it { is_expected.to have_db_column(:head_of_program_review_accepted_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:head_of_program_review_rejected_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:federal_funding).of_type(:boolean) }
  it { is_expected.to have_db_column(:placed_on_hold_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:removed_hold_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:proquest_agreement).of_type(:boolean) }
  it { is_expected.to have_db_column(:proquest_agreement_at).of_type(:datetime) }

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

  describe 'status validation' do
    it 'validates the inclusion of status in SubmissionStatus::WORKFLOW_STATUS array' do
      degree = FactoryBot.create :degree, degree_type: DegreeType.default
      submission = FactoryBot.create :submission, degree: degree
      expect(submission).to validate_inclusion_of(:status).in_array(SubmissionStatus::WORKFLOW_STATUS)
    end
  end

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

    it 'validates federal funding only when authors are editing beyond collecting committee' do
      submission = FactoryBot.create :submission, :waiting_for_final_submission_response
      submission2 = FactoryBot.create :submission, :collecting_program_information
      submission.author_edit = true
      submission.federal_funding = true
      expect(submission).to be_valid
      submission.federal_funding = false
      expect(submission).to be_valid
      submission.federal_funding = nil
      expect(submission).not_to be_valid
      submission2.federal_funding = nil
      expect(submission2).to be_valid
      submission.author_edit = false
      submission.federal_funding = nil
      expect(submission).to be_valid
    end

    it 'validates publication release if author is submitting beyond format review' do
      submission = FactoryBot.create :submission, :collecting_format_review_files
      submission2 = FactoryBot.create :submission, :collecting_final_submission_files
      submission.author.confidential_hold = true
      submission.author_edit = true
      submission.has_agreed_to_publication_release = false
      expect(submission).to be_valid
      submission.has_agreed_to_publication_release = nil
      expect(submission).to be_valid
      submission2.author.confidential_hold = true
      submission2.author_edit = false
      submission2.has_agreed_to_publication_release = nil
      expect(submission2).to be_valid
      submission2.author_edit = true
      submission2.has_agreed_to_publication_release = nil
      expect(submission2).not_to be_valid
    end

    it "validates proquest_agreement if graduate school, dissertation,
        and author is submitting beyond format review" do
      skip 'graduate only' unless current_partner.graduate?

      degree = FactoryBot.create :degree, degree_type: DegreeType.default
      submission = FactoryBot.create :submission, :collecting_format_review_files, degree: degree
      submission2 = FactoryBot.create :submission, :waiting_for_final_submission_response, degree: degree
      submission.author_edit = true
      submission.proquest_agreement = true
      expect(submission).to be_valid
      submission2.author_edit = true
      submission2.proquest_agreement = false
      expect(submission2).not_to be_valid
      submission2.author_edit = true
      submission2.proquest_agreement = true
      expect(submission2).to be_valid
    end
  end

  context 'invention disclosure' do
    it 'rejects an empty disclosure number' do
      expect(submission.reject_disclosure_number(id: nil, submission_id: nil, id_number: nil, created_at: nil, updated_at: nil)).to be_falsey
    end
  end

  context 'using lionpath?', lionpath: true do
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
    it 'returns a list of voting committee members', honors: true, milsch: true do
      degree = Degree.new(degree_type: DegreeType.default, name: 'mydegree')
      submission = Submission.new(degree: degree)
      submission.build_committee_members_for_partners
      submission.committee_members.each_with_index do |cm, index|
        next if index == 0

        cm.is_voting = true
        cm.access_id = 'abc123' if index == 1
        cm.access_id = 'abc123' if index == 2
        cm.access_id = 'abc456' if index == 3
        cm.access_id = 'abc789' if index == 4
        cm.access_id = 'abc321' if index == 5
      end
      expect(submission.voting_committee_members.count).to eq(submission.committee_members.to_ary.count - 2) if current_partner.graduate?
      expect(submission.voting_committee_members.count).to eq(submission.committee_members.to_ary.count - 1) unless current_partner.graduate?
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

  describe '#update_status_from_committee' do
    let!(:degree) { FactoryBot.create :degree, degree_type: DegreeType.default }
    let!(:degree_type) { FactoryBot.create :degree_type }
    let!(:approval_configuration) { FactoryBot.create :approval_configuration, head_of_program_is_approving: true, degree_type_id: degree_type.id }

    before do
      WorkflowMailer.deliveries = []
      submission.degree = degree
    end

    context 'when status is waiting for committee review' do
      context 'when approval status is approved' do
        it 'changes status to waiting for head of program review if program head is approving' do
          allow_any_instance_of(ApprovalStatus).to receive(:status).and_return('approved')
          allow_any_instance_of(ApprovalStatus).to receive(:head_of_program_status).and_return('')
          submission = FactoryBot.create :submission, :waiting_for_committee_review
          allow(CommitteeMember).to receive(:head_of_program).with(submission).and_return(FactoryBot.create(:committee_member))
          submission.update_status_from_committee
          expect(Submission.find(submission.id).status).to eq 'waiting for head of program review'
          expect(WorkflowMailer.deliveries.count).to eq 1
        end

        it 'changes status to waiting for final submission response' do
          allow_any_instance_of(Submission).to receive(:head_of_program_is_approving?).and_return false
          allow_any_instance_of(ApprovalStatus).to receive(:status).and_return('approved')
          submission = FactoryBot.create :submission, :waiting_for_committee_review
          allow(CommitteeMember).to receive(:head_of_program).with(submission).and_return(FactoryBot.create(:committee_member))
          submission.update_status_from_committee
          expect(Submission.find(submission.id).status).to eq 'waiting for final submission response'
          expect(WorkflowMailer.deliveries.count).to eq 0
        end
      end

      context 'when approval status is rejected' do
        it 'changes status to waiting for committee review rejected' do
          allow_any_instance_of(ApprovalStatus).to receive(:status).and_return('rejected')
          submission = FactoryBot.create :submission, :waiting_for_committee_review
          submission.update_status_from_committee
          expect(Submission.find(submission.id).status).to eq 'waiting for committee review rejected'
        end
      end
    end

    context 'when status is waiting for head of program review' do
      context 'when approval head of program status is approved' do
        it 'changes status to waiting for final submission response if graduate school' do
          allow_any_instance_of(ApprovalStatus).to receive(:head_of_program_status).and_return('approved')
          submission = FactoryBot.create :submission, :waiting_for_head_of_program_review
          submission.update_status_from_committee
          expect(Submission.find(submission.id).status).to eq 'waiting for final submission response'
        end
      end

      context 'when approval head of program status is rejected' do
        it 'changes status to waiting for committee review rejected' do
          allow_any_instance_of(ApprovalStatus).to receive(:head_of_program_status).and_return('rejected')
          submission = FactoryBot.create :submission, :waiting_for_head_of_program_review
          submission.update_status_from_committee
          expect(Submission.find(submission.id).status).to eq 'waiting for committee review rejected'
        end
      end
    end
  end

  describe "#committee_review_requests_init" do
    it 'sets approval_started_at timestamp for committee members' do
      submission = FactoryBot.create :submission
      create_committee submission
      submission.reload
      expect(submission.committee_members.first.approval_started_at).to be_falsey
      submission.committee_review_requests_init
      submission.reload
      expect(submission.committee_members.first.approval_started_at).to be_truthy
    end
  end

  describe "#proquest_agreement" do
    it "sets proquest_agreement_at when updated to 'true'" do
      skip 'graduate only' unless current_partner.graduate?

      submission = FactoryBot.create :submission, :collecting_final_submission_files,
                                     proquest_agreement: nil, proquest_agreement_at: nil
      submission.update proquest_agreement: true
      submission.reload
      expect(submission.proquest_agreement_at).to be_truthy
    end
  end
end
