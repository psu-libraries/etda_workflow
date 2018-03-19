require 'presenters/presenters_spec_helper'

RSpec.describe InboundLionPathView do
  if current_partner.graduate?

    author = FactoryBot.create :author
    InboundLionPathRecord.new(current_data: LionPath::MockLionPathRecord.current_data, author: author)
    submission = FactoryBot.create :submission, :final_is_restricted, author: author
    lp_view = described_class.new(submission)

    it 'returns a lion_path degree code' do
      expect(lp_view.degree).to eq(submission.program.name)
    end
    it 'returns a cleaned_title' do
      expect(lp_view.cleaned_title).to eq(submission.title)
    end

    it 'returns a formatted date' do
      status_date = Date.today
      expect(lp_view.send('format_date', status_date)).to eq(formatted_date(status_date))
    end

    it 'returns the status date' do
      submission_status_date = SubmissionStates::StateGenerator.state_for_name(submission.status).status_date(submission)
      expect(lp_view.status_date).to eql(formatted_date(submission_status_date))
    end
    it 'returns embargo start date for restricted submissions' do
      expect(lp_view.embargo_start).to eql('N/A') if submission.released_metadata_at.nil?
      expect(formatted_date(lp_view.embargo_start)).to eql(formatted_date(submission.released_metadata_at)) unless submission.released_metadata_at.nil?
    end

    it 'returns embargo end date for restricted submissions' do
      expect(lp_view.embargo_end).to eql('N/A') if submission.released_for_publication_at.nil?
      expect(formatted_date(lp_view.embargo_end)).to eql(submission.released_for_publication_at) unless submission.released_for_publication_at.nil?
    end

    it 'returns the release date' do
      submission.released_for_publication_at = Time.zone.now
      expect(lp_view.release_date).to eql(formatted_date(submission.released_for_publication_at))
    end

    it 'returns a degree code for PHD degrees' do
      phd_degree = Degree.create(degree_type_id: DegreeType.default.id, name: 'phd', description: 'phd degree')
      submission.degree_id = phd_degree.id
      expect(lp_view.degree_code).to eql('_PHD')
    end
    it 'returns a degree code for Master degrees' do
      master_degree = Degree.create(degree_type_id: DegreeType.last.id, name: 'ms', description: 'masters degree')
      submission.degree_id = master_degree.id
      expect(lp_view.degree_code).to eql('_MS')
    end
  end
end
