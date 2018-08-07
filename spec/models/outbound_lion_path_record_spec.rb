require 'model_spec_helper'
RSpec.describe OutboundLionPathRecord, type: :model do
  it { is_expected.to have_db_column(:transaction_id).of_type(:string) }
  it { is_expected.to have_db_column(:status_data).of_type(:text) }
  it { is_expected.to have_db_column(:received).of_type(:boolean) }
  it { is_expected.to have_db_column(:submission_id).of_type(:integer) }
  it { is_expected.to have_db_column(:created_at).of_type(:datetime) }
  it { is_expected.to have_db_column(:updated_at).of_type(:datetime) }
  it { is_expected.to validate_presence_of(:transaction_id) }
  it { is_expected.to validate_presence_of(:status_data) }

  context '#active?' do
    it 'returns value from lion_path.yml' do
      expect(described_class.active?).to eql(Rails.application.config_for(:lion_path)[current_partner.id.to_s][:lion_path_outbound])
    end
  end

  if described_class.active?
    let(:author) { create :author, alternate_email_address: 'original@gmail.com' }
    let(:fake_date) { Time.zone.yesterday.to_datetime }
    let(:submission) { create :submission, :released_for_publication, author: author, access_level: AccessLevel.OPEN_ACCESS }

    describe 'builds and serializes a status record' do
      it 'returns a hash of attributes from the author and submission' do
        subject = described_class.new(submission: submission).send(:status_record_data)
        expect(subject).to be_a(Array)
        expect(subject.first[:thesis_title]).to eql(submission.cleaned_title)
        expect(subject.first[:access_level]).to eql(LionPath::Crosswalk.etd_to_lp_access(submission.access_level))
      end
    end

    describe 'creates an outbound_lion_path record' do
      it 'calls report_status_change when the submission status changes' do
        count = described_class.all.count
        submission.access_level = AccessLevel.RESTRICTED
        described_class.new(submission: submission).report_status_change
        new_count = described_class.all.count
        expect(count + 1).to eql(new_count)
        db_record = described_class.last
        expect(db_record.submission_id).to eq(submission.id)
        expect(db_record.transaction_id).to eq(submission.id.to_s)
        expect(db_record.status_data.first[:thesis_title]).to eq(submission.cleaned_title)
        expect(db_record.status_data.first[:thesis_status_date]).to eq(submission.released_for_publication_at.strftime('%m-%d-%Y'))
        expect(db_record.status_data.first[:thesis_status]).to eq(submission.status)
        expect(db_record.status_data.first[:access_level]).to eq(LionPath::Crosswalk.etd_to_lp_access(submission.access_level))
        expect(db_record.status_data.first[:embargo_start_date]).to eq(submission.released_metadata_at.strftime('%m-%d-%Y'))
        expect(db_record.status_data.first[:embargo_end_date]).to eq(submission.released_for_publication_at.strftime('%m-%d-%Y'))
      end
      it 'calls report_title_change when a title changes' do
        count = described_class.all.count
        lp_record = described_class.new(submission: submission, original_title: submission.title)
        submission.title = 'changed title'
        submission.author.alternate_email_address = 'changed@gmail.com'
        lp_record.report_title_change
        new_count = described_class.all.count
        expect(count + 1).to eql(new_count)
        db_record = described_class.last
        expect(db_record.submission_id).to eq(submission.id)
        expect(db_record.transaction_id).to eq(submission.id.to_s)
        expect(db_record.status_data.first[:thesis_title]).to eq(submission.cleaned_title)
        expect(db_record.status_data.first[:thesis_status_date]).to eq(submission.updated_at)
        expect(db_record.status_data.first[:thesis_status]).to eq(submission.status)
        expect(db_record.status_data.first[:access_level]).to eq(LionPath::Crosswalk.etd_to_lp_access(submission.access_level))
      end
      it 'calls report_deleted_submission when submissions are deleted' do
        count = described_class.all.count
        lp_record = described_class.new(submission: submission)
        lp_record.report_deleted_submission
        new_count = described_class.all.count
        expect(count + 1).to eql(new_count)
        db_record = described_class.last
        expect(db_record.submission_id).to eq(submission.id)
        expect(db_record.transaction_id).to eq(submission.id.to_s)

        expect(db_record.status_data.first[:thesis_title]).to eq(submission.cleaned_title)
        expect(Time.zone.now).to be_within(2.0).of(Time.zone.parse(db_record.status_data.first[:thesis_status_date]))
        expect(db_record.status_data.first[:thesis_status]).to eq("#{submission.status}-Deleted")
        expect(db_record.status_data.first[:access_level]).to eq(LionPath::Crosswalk.etd_to_lp_access(submission.access_level))
      end
      it 'calls report_email_change when an alternate email address changes' do
        count = described_class.all.count
        lp_record = described_class.new(submission: submission, original_alternate_email: submission.author.alternate_email_address)
        submission.author.alternate_email_address = 'NEWEMAILADDRESS@gmail.com'
        lp_record.report_email_change
        new_count = described_class.all.count
        expect(count + 1).to eql(new_count)
        db_record = described_class.last
        expect(db_record.submission_id).to eq(submission.id)
        expect(db_record.transaction_id).to eq(submission.id.to_s)
        expect(db_record.status_data.first[:thesis_title]).to eq(submission.cleaned_title)
        expect(db_record.status_data.first[:thesis_status_date]).to eq(submission.updated_at)
        expect(db_record.status_data.first[:thesis_status]).to eq(submission.status)
        expect(db_record.status_data.first[:access_level]).to eq(LionPath::Crosswalk.etd_to_lp_access(submission.access_level))
      end
      it 'does not report_email_change when an alternate email address does not change' do
        submission.author.alternate_email_address = 'testing@gmail.com'
        count = described_class.all.count
        lp_record = described_class.new(submission: submission, original_alternate_email: submission.author.alternate_email_address)
        lp_record.report_email_change
        new_count = described_class.all.count
        expect(count).to eql(new_count)
      end
      it 'does not report_title_change when title does not change or is nil' do
        count = described_class.all.count
        lp_record = described_class.new(submission: submission, original_title: nil)
        lp_record.report_title_change
        new_count = described_class.all.count
        expect(count).to eql(new_count)
      end
    end
  end
end
