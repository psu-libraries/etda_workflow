require 'presenters/presenters_spec_helper'

RSpec.describe Admin::SubmissionView, type: :decorator do
  author = FactoryBot.create :author
  submission = FactoryBot.create(:submission, :released_for_publication, author:)
  time_yesterday = Time.zone.yesterday
  formatted_yesterday = formatted_time(time_yesterday)

  describe '#table_title' do
    it 'returns the title' do
      expect(described_class.new(submission, nil).table_title).to eql(submission.title)
    end
  end

  context 'released_for_publication_date' do
    it 'returns date when publication was released' do
      submission.released_for_publication_at = time_yesterday
      decorator = described_class.new(submission, nil)
      expect(formatted_time(decorator.released_for_publication_at)).to eql(formatted_yesterday)
    end
  end

  context 'format_review_files_uploaded_date' do
    it 'returns the date when format review files were uploaded' do
      yesterday_date = Date.yesterday
      submission.format_review_files_first_uploaded_at = yesterday_date
      decorator = described_class.new(submission, nil)
      expect(decorator.format_review_files_uploaded_date).to eql(formatted_date(yesterday_date))
    end
  end

  context 'final_submission_files_uploaded_date' do
    it 'returns the date when final submission files were uploaded' do
      submission.final_submission_files_first_uploaded_at = time_yesterday
      decorator = described_class.new(submission, nil)
      expect(formatted_time(decorator.final_submission_files_first_uploaded_at)).to eql(formatted_yesterday)
    end
  end

  context 'creation_date' do
    it 'returns the submission creation date' do
      date_yesterday = Date.yesterday
      submission.created_at = time_yesterday
      decorator = described_class.new(submission, nil)
      expect(decorator.creation_date).to eql(formatted_date(date_yesterday))
    end
  end

  context 'indicator_labels' do
    it 'returns Rejected label when appropriate' do
      rejected_indicator = '<span class="label label-warning">Rejected</span> '
      submission.status = 'collecting format review files rejected'
      submission.format_review_rejected_at = Time.zone.yesterday
      decorator = described_class.new(submission, nil)
      expect(decorator.indicator_labels).to eql(rejected_indicator)
      submission.status = 'collecting final submission files rejected'
      submission.final_submission_rejected_at = Time.zone.yesterday
      decorator = described_class.new(submission, nil)
      expect(decorator.indicator_labels).to eql(rejected_indicator)
      submission.status = 'collecting program information'
      submission.format_review_rejected_at = nil
      decorator = described_class.new(submission, nil)
      expect(decorator.indicator_labels).to eql('')
    end
  end
end
