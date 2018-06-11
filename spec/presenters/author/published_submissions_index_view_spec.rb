require 'presenters/presenters_spec_helper'
RSpec.describe Author::PublishedSubmissionsIndexView do
    let(:author) { FactoryBot.create :author }
    let(:submission) { FactoryBot.create :submission, :released_for_publication, author: author, public_id: 'public-id123' }
    let(:view) { described_class.new(author) }

    describe 'author view for released submissions' do
      it "#title_link returns a link to the author's published submission" do
        expect(view.title_link(submission)).to eq("<span class='sr-only'>link to your submission #{submission.cleaned_title} opens in a new tab</span> <a target = blank href = '#{WebAccess.new.explore_base_url}/catalog/#{submission.public_id}' class='title'> #{submission.cleaned_title} </a>")
      end
      it "#release information returns publication date for open_access and restricted_to_institution submissions" do
        date = submission.released_for_publication_at.strftime('%B %-e, %Y')
        expect(view.release_information(submission)).to eql(
          '<strong>Publication Date: </strong>' + date
        )
      end
      it "returns metadata publication date for restricted submissions" do
        restricted_submission = FactoryBot.create :submission, :final_is_restricted, author: author, public_id: 'public-id456'
        date = restricted_submission.released_metadata_at.strftime('%B %-e, %Y')
        expect(view.release_information(restricted_submission)).to eql('<strong>Abstract Publish Date: </strong>' + date)
      end
    end
end
