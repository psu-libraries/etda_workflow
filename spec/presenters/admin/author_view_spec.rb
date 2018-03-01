require 'presenters/presenters_spec_helper'
RSpec.describe Admin::AuthorView do
  let(:author) { FactoryBot.create :author }
  let(:view) { described_class.new(author) }

  context 'submission_list' do
    it 'returns a list of submissions with most recent submissions first' do
      submission1 = FactoryBot.create :submission, :waiting_for_final_submission_response, created_at: Time.zone.now - 2.years
      submission2 = FactoryBot.create :submission, :released_for_publication, created_at: Time.zone.now
      author.submissions = [submission1, submission2]
      submission_list =  "<ul><li><a href='/admin/submissions/#{submission2.id}/edit'>#{submission2.title}</a><br/>status: #{submission2.status}, created: #{Time.zone.now.strftime('%m/%d/%Y')}</li><li><a href='/admin/submissions/#{submission1.id}/edit'>#{submission1.title}</a><br/>status: #{submission1.status}, created: #{(Time.zone.now - 2.years).strftime('%m/%d/%Y')}</li></ul>"
      expect(author.submissions.count).to eq(2)
      expect(view.submission_list).to eql(submission_list)
    end
    it 'returns a message when no submissions exist for the author' do
      author.submissions = []
      expect(author.submissions.count).to eq(0)
      expect(view.submission_list).to eq('<p>No submissions for this author</p>')
    end
    it 'returns a list item without a link if submission does not have a format review file' do
      submission_new = FactoryBot.create :submission, :collecting_committee, created_at: Time.zone.now
      author.submissions = [submission_new]
      expect(view.submission_list).to eq("<ul><li>#{submission_new.title}<br/>status: #{submission_new.status}, created: #{Time.zone.now.strftime('%m/%d/%Y')}</li></ul>")
    end
  end
end
