require 'presenters/presenters_spec_helper'
RSpec.describe Author::PublishedSubmissionsIndexView do
  describe 'author view for released submissions' do
    author = FactoryBot.create :author
    submission = FactoryBot.create :submission, :released_for_publication, public_id: 'public-id123', author: author
    let(:view) { described_class.new(author) }

    it "#title_link returns a link to the author's published submission" do
      expect(view.title_link(submission)).to eq("<span class='sr-only'>link to your submission #{submission.cleaned_title} opens in a new tab</span> <a target = blank href = '#{WebAccess.new.explore_base_url}/catalog/#{submission.public_id}' class='title'> #{submission.cleaned_title} </a>")
    end
    it "#release information returns publication date for open_access and restricted_to_institution submissions" do
      date = submission.released_for_publication_at.strftime('%B %-e, %Y')
      expect(view.release_information(submission)).to eql(
        '<strong>Publication Date: </strong>' + date
      )
    end
    it "returns 'published_submissions' partial when author has publications" do
      published_author = FactoryBot.create :author
      FactoryBot.create :submission, :released_for_publication, public_id: 'public-id123', author: published_author
      view = described_class.new(published_author)
      expect(view.published_submissions_partial).to eq('published_submissions')
    end
    it "returns metadata publication date for restricted submissions" do
      restricted_author = FactoryBot.create :author
      restricted_submission = FactoryBot.create :submission, :final_is_restricted, author: restricted_author, public_id: 'public-id456'
      date = restricted_submission.released_metadata_at.strftime('%B %-e, %Y')
      expect(view.release_information(restricted_submission)).to eql('<strong>Abstract Publish Date: </strong>' + date)
    end
    it "returns 'no_published_submissions' partial when author has no publications" do
      expect(author.submissions.count).to eq(0)
      expect(view.published_submissions_partial).to eq('no_published_submissions')
    end
  end
end
