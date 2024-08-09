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
  it { is_expected.to have_db_column(:lionpath_updated_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:campus).of_type(:string) }
  it { is_expected.to have_db_column(:lionpath_semester).of_type(:string) }
  it { is_expected.to have_db_column(:lionpath_year).of_type(:integer) }
  it { is_expected.to have_db_column(:extension_token).of_type(:string) }

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
  it { is_expected.to have_many :admin_feedback_files }
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

  describe '.ok_to_autorelease' do
    let!(:sub1) do
      FactoryBot.create :submission,
                        released_for_publication_at: Time.zone.today.days_ago(1),
                        access_level: 'restricted_to_institution'
    end
    let!(:sub2) do
      FactoryBot.create :submission,
                        released_for_publication_at: Time.zone.today,
                        access_level: 'restricted_to_institution'
    end
    let!(:sub3) do
      FactoryBot.create :submission,
                        released_for_publication_at: Time.zone.today.next_week,
                        access_level: 'restricted_to_institution'
    end
    let!(:sub4) do
      FactoryBot.create :submission,
                        released_for_publication_at: Time.zone.today.days_ago(1),
                        access_level: 'open_access'
    end

    it 'returns submissions that are ready for autorelease' do
      expect(described_class.ok_to_autorelease).to contain_exactly(sub1, sub2)
    end
  end

  describe '.release_warning_needed?' do
    let!(:sub1) do
      FactoryBot.create :submission,
                        released_for_publication_at: Time.zone.today.next_month,
                        released_metadata_at: Time.zone.today.years_ago(1),
                        access_level: 'restricted_to_institution'
    end
    let!(:sub2) do
      FactoryBot.create :submission,
                        released_metadata_at: Time.zone.today.years_ago(1),
                        author_release_warning_sent_at: Time.zone.today.last_week,
                        access_level: 'restricted_to_institution'
    end
    let!(:sub3) do
      FactoryBot.create :submission,
                        released_for_publication_at: Time.zone.today.next_month,
                        released_metadata_at: Time.zone.today.years_ago(3),
                        access_level: 'restricted_to_institution'
    end
    let!(:sub4) do
      FactoryBot.create :submission,
                        released_for_publication_at: Time.zone.today + 6.weeks,
                        released_metadata_at: Time.zone.today.years_ago(1)
    end

    it 'returns submissions that are ready for autorelease' do
      expect(described_class.release_warning_needed?).to contain_exactly(sub1)
    end
  end

  describe '#advisor' do
    it 'returns the advisor committee member for the submission' do
      submission = FactoryBot.create :submission
      advisor_role = FactoryBot.create :committee_role, name: 'Submission Advisor'
      non_advisor_role = FactoryBot.create :committee_role, name: 'Committee Member'
      committee_member1 = FactoryBot.create :committee_member, committee_role: advisor_role
      committee_member2 = FactoryBot.create :committee_member, committee_role: non_advisor_role
      expect(submission.advisor).to eq nil
      submission.committee_members << committee_member2
      submission.reload
      expect(submission.advisor).to eq nil
      submission.committee_members << committee_member1
      submission.reload
      expect(submission.advisor).to eq committee_member1
    end
  end

  describe 'status validation' do
    it 'validates the inclusion of status in SubmissionStatus::WORKFLOW_STATUS array' do
      degree = FactoryBot.create :degree, degree_type: DegreeType.default
      submission = FactoryBot.create(:submission, degree:)
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

    it "validates year only when authors are editing" do
      submission = FactoryBot.create :submission
      submission.update(year: '2018')
      expect(submission).to be_valid
      submission.update(year: '')
      submission.author_edit = true
      expect(submission).not_to be_valid
      submission.update(year: 'abc')
      expect(submission).not_to be_valid
      submission.author_edit = false
      expect(submission).to be_valid
      submission.update(year: '')
      expect(submission).to be_valid
    end

    it "validates semester only when authors are editing" do
      submission = FactoryBot.create :submission
      submission.update(semester: 'Spring')
      expect(submission).to be_valid
      submission.update(semester: '')
      submission.author_edit = true
      expect(submission).not_to be_valid
      submission.update(semester: 'abc')
      expect(submission).not_to be_valid
      submission.author_edit = false
      expect(submission).to be_valid
      submission.update(semester: '')
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
      submission.format_review_files << create(:format_review_file)
      submission.save!
      submission2.final_submission_files << create(:final_submission_file)
      submission2.save!
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
      submission = FactoryBot.create(:submission, :collecting_format_review_files, degree:)
      submission2 = FactoryBot.create(:submission, :waiting_for_final_submission_response, degree:)
      submission.format_review_files << create(:format_review_file)
      submission.save!
      submission2.final_submission_files << create(:final_submission_file)
      submission2.save!
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

    it "validates lionpath_semester is in Semester::SEMESTERS list" do
      submission = FactoryBot.create :submission
      submission.update(lionpath_semester: 'Fall')
      expect(submission).to be_valid
      submission.update(lionpath_semester: '')
      expect(submission).to be_valid
      submission.update(lionpath_semester: nil)
      expect(submission).to be_valid
      submission.update(lionpath_semester: 'bogus')
      expect(submission).not_to be_valid
    end

    it "validates lionpath_year is numbers" do
      submission = FactoryBot.create :submission
      submission.update(lionpath_year: '2021')
      expect(submission).to be_valid
      submission.update(lionpath_year: '')
      expect(submission).to be_valid
      submission.update(lionpath_year: nil)
      expect(submission).to be_valid
      submission.update(lionpath_year: 'bogus')
      expect(submission).not_to be_valid
    end

    describe "validating file upload for authors at format review and final submission stages" do
      context "when collecting_format_review_files" do
        let!(:test_submission) { FactoryBot.create(:submission, :collecting_format_review_files) }

        context "when author is editing" do
          before do
            test_submission.author_edit = true
          end

          context "when format review file is uploaded" do
            before do
              test_submission.format_review_files << create(:format_review_file)
              test_submission.save!
            end

            it 'is valid' do
              expect(test_submission.valid?).to be true
            end
          end

          context "when format review file is not uploaded" do
            it 'is invalid' do
              expect(test_submission.valid?).to be false
              expect(test_submission.errors.full_messages).to eq ['Format review file You must upload a Format Review file.']
            end
          end
        end

        context "when author is not editing" do
          before do
            test_submission.author_edit = false
          end

          context "when format review file is uploaded" do
            before do
              test_submission.format_review_files << create(:format_review_file)
              test_submission.save!
            end

            it 'is valid' do
              expect(test_submission.valid?).to be true
            end
          end

          context "when format review file is not uploaded" do
            it 'is valid' do
              expect(test_submission.valid?).to be true
            end
          end
        end
      end

      context "when collecting_format_review_files_rejected" do
        let!(:test_submission) { FactoryBot.create(:submission, :collecting_format_review_files_rejected) }

        context "when author is editing" do
          before do
            test_submission.author_edit = true
          end

          context "when format review file is uploaded" do
            before do
              test_submission.format_review_files << create(:format_review_file)
              test_submission.save!
            end

            it 'is valid' do
              expect(test_submission.valid?).to be true
            end
          end

          context "when format review file is not uploaded" do
            it 'is invalid' do
              expect(test_submission.valid?).to be false
              expect(test_submission.errors.full_messages).to eq ['Format review file You must upload a Format Review file.']
            end
          end
        end

        context "when author is not editing" do
          before do
            test_submission.author_edit = false
          end

          context "when format review file is uploaded" do
            before do
              test_submission.format_review_files << create(:format_review_file)
              test_submission.save!
            end

            it 'is valid' do
              expect(test_submission.valid?).to be true
            end
          end

          context "when format review file is not uploaded" do
            it 'is valid' do
              expect(test_submission.valid?).to be true
            end
          end
        end
      end

      context "when collecting_final_submission_files" do
        let!(:test_submission) do
          FactoryBot.create(:submission, :collecting_final_submission_files,
                            abstract: 'Abstract',
                            has_agreed_to_terms: true,
                            proquest_agreement: true)
        end

        context "when author is editing" do
          before do
            test_submission.author_edit = true
          end

          context "when final submission file is uploaded" do
            before do
              test_submission.final_submission_files << create(:final_submission_file)
              test_submission.save!
            end

            it 'is valid' do
              expect(test_submission.valid?).to be true
            end
          end

          context "when final submission file is not uploaded" do
            it 'is invalid' do
              expect(test_submission.valid?).to be false
              expect(test_submission.errors.full_messages).to eq ['Final submission file You must upload a Final Submission file.']
            end
          end
        end

        context "when author is not editing" do
          before do
            test_submission.author_edit = false
          end

          context "when final submission file is uploaded" do
            before do
              test_submission.final_submission_files << create(:final_submission_file)
              test_submission.save!
            end

            it 'is valid' do
              expect(test_submission.valid?).to be true
            end
          end

          context "when final submission file is not uploaded" do
            it 'is valid' do
              expect(test_submission.valid?).to be true
            end
          end
        end
      end

      context "when collecting_final_submission_files_rejected" do
        let!(:test_submission) do
          FactoryBot.create(:submission, :collecting_final_submission_files_rejected,
                            abstract: 'Abstract',
                            has_agreed_to_terms: true,
                            proquest_agreement: true)
        end

        context "when author is editing" do
          before do
            test_submission.author_edit = true
          end

          context "when final submission file is uploaded" do
            before do
              test_submission.final_submission_files << create(:final_submission_file)
              test_submission.save!
            end

            it 'is valid' do
              expect(test_submission.valid?).to be true
            end
          end

          context "when final submission file is not uploaded" do
            it 'is invalid' do
              expect(test_submission.valid?).to be false
              expect(test_submission.errors.full_messages).to eq ['Final submission file You must upload a Final Submission file.']
            end
          end
        end

        context "when author is not editing" do
          before do
            test_submission.author_edit = false
          end

          context "when final submission file is uploaded" do
            before do
              test_submission.final_submission_files << create(:final_submission_file)
              test_submission.save!
            end

            it 'is valid' do
              expect(test_submission.valid?).to be true
            end
          end

          context "when final submission file is not uploaded" do
            it 'is valid' do
              expect(test_submission.valid?).to be true
            end
          end
        end
      end

      context "when waiting_for_committee_review_rejected" do
        let!(:test_submission) do
          FactoryBot.create(:submission, :waiting_for_committee_review_rejected,
                            abstract: 'Abstract',
                            has_agreed_to_terms: true,
                            proquest_agreement: true)
        end

        context "when author is editing" do
          before do
            test_submission.author_edit = true
          end

          context "when final submission file is uploaded" do
            before do
              test_submission.final_submission_files << create(:final_submission_file)
              test_submission.save!
            end

            it 'is valid' do
              expect(test_submission.valid?).to be true
            end
          end

          context "when final submission file is not uploaded" do
            it 'is invalid' do
              expect(test_submission.valid?).to be false
              expect(test_submission.errors.full_messages).to eq ['Final submission file You must upload a Final Submission file.']
            end
          end
        end

        context "when author is not editing" do
          before do
            test_submission.author_edit = false
          end

          context "when final submission file is uploaded" do
            before do
              test_submission.final_submission_files << create(:final_submission_file)
              test_submission.save!
            end

            it 'is valid' do
              expect(test_submission.valid?).to be true
            end
          end

          context "when final submission file is not uploaded" do
            it 'is valid' do
              expect(test_submission.valid?).to be true
            end
          end
        end
      end
    end
  end

  context 'invention disclosure' do
    it 'rejects an empty disclosure number' do
      expect(submission.reject_disclosure_number(id: nil, submission_id: nil, id_number: nil, created_at: nil, updated_at: nil)).to be_falsey
    end
  end

  context 'keywords' do
    it 'has a list of keywords' do
      submission = described_class.new
      submission.keywords << Keyword.new(word: 'zero')
      submission.keywords << Keyword.new(word: 'one')
      submission.keywords << Keyword.new(word: 'two')
      expect(submission.delimited_keywords).to eq('zero,one,two')
      expect(submission.keyword_list).to eq(['zero', 'one', 'two'])
    end
  end

  describe '#defended_at_date' do
    it 'returns defended_at date from student input' do
      submission = FactoryBot.create :submission, :released_for_publication
      expect(submission.defended_at).not_to be_blank if current_partner.graduate?
    end
  end

  describe '#federal_funding_display' do
    context 'when federal_funding is nil' do
      it 'returns nil' do
        submission = described_class.new(federal_funding: nil)
        expect(submission.federal_funding_display).to be_nil
      end
    end

    context 'when federal_funding is false' do
      it 'returns No' do
        submission = described_class.new(federal_funding: false)
        expect(submission.federal_funding_display).to eq('No')
      end
    end

    context 'when federal_funding is true' do
      it 'returns Yes' do
        submission = described_class.new(federal_funding: true)
        expect(submission.federal_funding_display).to eq('Yes')
      end
    end
  end

  describe '#check_title_capitalization' do
    it 'identifies all caps in the title' do
      submission = described_class.new(title: 'THIS TITLE IS NOT ALLOWED')
      expect(submission.check_title_capitalization).to eq(["Please check that the title is properly capitalized. If you need to use upper-case words such as acronyms, you must select the option to allow it."])
      expect(submission.errors[:title]).to eq(["Please check that the title is properly capitalized. If you need to use upper-case words such as acronyms, you must select the option to allow it."])
    end

    it 'allows titles with < 4 uppercase, numbers, and symbols' do
      submission = described_class.new(title: 'THIS 1855 is %^&**% AlloweD')
      expect(submission.check_title_capitalization).to eq(nil)
      expect(submission.errors[:title]).to eq([])
    end
  end

  describe '#check_title_capitalization' do
    it 'identifies all caps in the title' do
      submission = described_class.new(title: 'THIS TITLE IS NOT ALLOWED')
      expect(submission.check_title_capitalization).to eq(["Please check that the title is properly capitalized. If you need to use upper-case words such as acronyms, you must select the option to allow it."])
      expect(submission.errors[:title]).to eq(["Please check that the title is properly capitalized. If you need to use upper-case words such as acronyms, you must select the option to allow it."])
    end

    it 'allows titles with < 4 uppercase, numbers, and symbols' do
      submission = described_class.new(title: 'THIS 1855 is %^&**% AlloweD')
      expect(submission.check_title_capitalization).to eq(nil)
      expect(submission.errors[:title]).to eq([])
    end
  end

  describe '#restricted_to_institution?' do
    it 'returns true' do
      submission = described_class.new(access_level: 'restricted_to_institution')
      expect(submission).to be_restricted_to_institution
      submission.access_level = 'restricted'
      expect(submission).not_to be_restricted_to_institution
    end
  end

  describe '#voting_committee_members' do
    let!(:degree2) { FactoryBot.create :degree, degree_type: DegreeType.default, name: 'mydegree' }
    let!(:submission2) { FactoryBot.create :submission, degree: degree2 }
    let(:head_role) { CommitteeRole.find_by(degree_type: degree2.degree_type, is_program_head: true) }

    context 'when head of program is approving' do
      it 'returns a list of voting committee members without duplication that does not include program head' do
        allow(submission2).to receive(:head_of_program_is_approving?).and_return true
        create_committee(submission2)
        submission2.committee_members.each_with_index do |cm, index|
          if index == 0
            cm.committee_role = head_role
            cm.is_voting = false
            cm.access_id = 'abc'
            cm.save!
            next
          end

          cm.is_voting = true
          cm.access_id = 'abc123' if index == 1
          cm.access_id = 'abc123' if index == 2
          cm.access_id = 'abc456' if index == 3
          cm.access_id = 'abc789' if index == 4
          cm.access_id = 'abc321' if index == 5
          cm.save!
        end
        submission2.reload
        expect(submission2.voting_committee_members.count).to eq(submission2.committee_members.count - 2)
      end
    end

    context 'when head of program is not approving' do
      it 'returns a list of voting committee members without duplication that includes the program head' do
        allow(submission2).to receive(:head_of_program_is_approving?).and_return false
        create_committee(submission2)
        submission2.committee_members.each_with_index do |cm, index|
          if index == 0
            cm.committee_role = head_role
            cm.is_voting = false
            cm.access_id = 'abc'
            cm.save!
            next
          end

          cm.is_voting = true
          cm.access_id = 'abc123' if index == 1
          cm.access_id = 'abc123' if index == 2
          cm.access_id = 'abc456' if index == 3
          cm.access_id = 'abc789' if index == 4
          cm.access_id = 'abc321' if index == 5
          cm.save!
        end
        submission2.reload
        expect(submission2.voting_committee_members.count).to eq(submission2.committee_members.count - 1)
      end
    end
  end

  describe '#build_committee_members_for_partners' do
    context "when a Program Head/Chair doesn't already exist" do
      it 'returns a list of required committee members' do
        degree = Degree.new(degree_type: DegreeType.default, name: 'mydegree')
        submission = described_class.new(degree:)
        expect(submission.build_committee_members_for_partners).not_to be_blank
      end
    end

    context "when a Program Head/Chair already exists" do
      it 'returns a list of required committee members' do
        degree = FactoryBot.create :degree
        submission = FactoryBot.create(:submission, degree:)
        expect(submission.build_committee_members_for_partners).not_to be_blank
        expect(submission.committee_members.to_ary.count).to eq submission.required_committee_roles.count
      end
    end
  end

  describe '#publication_release_date' do
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
      time_now = Time.zone.now
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
      time_now = Time.zone.now
      time_now_formatted = formatted_time(time_now)
      # time_now_formatted = time_now.strftime("%Y-%m-%d %H:%M:%S.000000000 -0500")
      submission.update_final_submission_timestamps!(time_now)
      expect(formatted_time(submission.final_submission_files_uploaded_at)).to eq(time_now_formatted)
      expect(formatted_time(submission.final_submission_files_first_uploaded_at)).to eq(time_now_formatted)
    end
  end

  describe "#committee_review_requests_init", honors: true do
    it 'sets approval_started_at timestamp for committee members and sends email to committee members only once' do
      submission = FactoryBot.create :submission
      allow(submission).to receive(:head_of_program_is_approving?).and_return false
      create_committee submission
      if current_partner.graduate?
        submission.committee_members.second.update access_id: 'abc123'
        submission.committee_members.third.update access_id: 'abc123'
      end
      submission.reload
      submission.committee_review_requests_init
      submission.reload
      expect(submission.committee_members.pluck(:approval_started_at).compact.count).to eq submission.committee_members.count - 1 if current_partner.graduate?
      expect(submission.committee_members.pluck(:approval_started_at).compact.count).to eq submission.committee_members.count unless current_partner.graduate?
      expect(WorkflowMailer.deliveries.count).to eq submission.committee_members.count - 2 if current_partner.graduate?
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

  describe "#create_extension_token" do
    it 'generates a unique token string for extension_token' do
      submission = FactoryBot.create :submission, extension_token: nil
      submission.create_extension_token
      submission.reload
      expect(submission.extension_token).not_to be_nil
      expect(described_class.where(extension_token: submission.extension_token).count).to eq 1
    end
  end

  describe "#committee_email_list" do
    let!(:new_submission) { FactoryBot.create :submission }
    let!(:head_role) { FactoryBot.create :committee_role, is_program_head: true }

    it 'returns a list of emails' do
      create_committee(new_submission)
      new_submission.committee_members << (FactoryBot.create :committee_member, committee_role: head_role, email: 'xxx1@psu.edu')
      new_submission.committee_members.first.update email: "sameemail@psu.edu"
      new_submission.committee_members.second.update email: "sameemail@psu.edu"
      expect(new_submission.committee_email_list).to eq ["sameemail@psu.edu",
                                                         new_submission.committee_members.third.email,
                                                         new_submission.committee_members.fourth.email,
                                                         new_submission.committee_members.fifth.email,
                                                         new_submission.committee_members[5].email, "xxx1@psu.edu"]
    end
  end

  describe "#preferred_year" do
    context 'when year is present but lionpath_year is not' do
      it 'returns year' do
        submission.lionpath_year = nil
        submission.year = Date.today.year
        expect(submission.preferred_year).to eq submission.year
      end
    end

    context 'when lionpath_year is present but year is not' do
      it 'returns lionpath_year' do
        submission.lionpath_year = Date.today.year
        submission.year = nil
        expect(submission.preferred_year).to eq submission.lionpath_year
      end
    end

    context 'when year is present and lionpath_year is present' do
      it 'returns year' do
        submission.lionpath_year = Date.today.year
        submission.year = Date.today.year
        expect(submission.preferred_year).to eq submission.year
      end
    end
  end

  describe "#preferred_semester" do
    context 'when semester is present but lionpath_semester is not' do
      it 'returns semester' do
        submission.lionpath_semester = nil
        submission.semester = 'Spring'
        expect(submission.preferred_semester).to eq submission.semester
      end
    end

    context 'when lionpath_semester is present but semester is not' do
      it 'returns lionpath_semester' do
        submission.lionpath_semester = 'Fall'
        submission.semester = nil
        expect(submission.preferred_semester).to eq submission.lionpath_semester
      end
    end

    context 'when semester is present and lionpath_semester is present' do
      it 'returns semester' do
        submission.lionpath_semester = 'Spring'
        submission.semester = 'Fall'
        expect(submission.preferred_semester).to eq submission.semester
      end
    end
  end

  describe "#preferred_semester_and_year" do
    context 'when year and semester are present but lionpath_year and lionpath_semester are not' do
      it 'uses the year and semester' do
        submission.lionpath_year = nil
        submission.lionpath_semester = nil
        expect(submission.preferred_semester_and_year)
          .to eq "#{submission.semester} #{submission.year}"
      end
    end

    context 'when lionpath_year and lionpath_semester are present but year and semester are not' do
      it 'uses the imported year and semester' do
        submission.lionpath_year = Date.today.year
        submission.lionpath_semester = 'Spring'
        submission.year = nil
        submission.semester = nil
        expect(submission.preferred_semester_and_year)
          .to eq "#{submission.lionpath_semester} #{submission.lionpath_year}"
      end
    end

    context 'when year and semester are present and lionpath_year and lionpath_semester are present' do
      it 'uses the year and semester' do
        submission.lionpath_year = Date.today.year
        submission.lionpath_semester = 'Spring'
        submission.year = (Date.today.year + 1.year)
        submission.semester = 'Fall'
        expect(submission.preferred_semester_and_year)
          .to eq "#{submission.semester} #{submission.year}"
      end
    end
  end

  describe "#final_submission_feedback_files?" do
    it 'returns true if at least one admin feedback file with type final-submission' do
      sub1 = described_class.new
      sub1.admin_feedback_files.build(feedback_type: 'final-submission')
      expect(sub1).to be_final_submission_feedback_files
    end

    it 'returns false if no admin feedback file has the type of final-submission' do
      sub2 = described_class.new
      sub2.admin_feedback_files.build(feedback_type: 'format-review')
      expect(sub2).not_to be_final_submission_feedback_files
    end
  end

  describe "#format_review_feedback_files?" do
    it 'returns true if at least one admin feedback file with type format-review' do
      sub3 = described_class.new
      sub3.admin_feedback_files.build(feedback_type: 'format-review')
      expect(sub3).to be_format_review_feedback_files
    end

    it 'returns false if no admin feedback file has the type of format-review' do
      sub4 = described_class.new
      sub4.admin_feedback_files.build(feedback_type: 'final-submission')
      expect(sub4).not_to be_format_review_feedback_files
    end
  end
end
